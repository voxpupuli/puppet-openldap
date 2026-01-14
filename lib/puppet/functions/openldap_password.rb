# frozen_string_literal: true
require 'openssl'
require 'digest'
require 'base64'
#
# @summary
#         Returns the openldap password hash from the clear text password.
#
#
Puppet::Functions.create_function(:openldap_password) do
  # @param secret
  #   The secret to be hashed.
  #
  # @param scheme
  #   The optional scheme to use (defaults to SSHA).
  #
  # @return [String]
  #   The hashed secret.
  #
  dispatch :generate_password do
    required_param 'String', :secret
    optional_param 'Enum["PBKDF2","CRYPT","MD5","SMD5","SSHA","SHA"]', :scheme
    optional_param 'Integer', :iterations

    return_type 'String'
  end

  def generate_password(secret, scheme = 'SSHA', iterations = 60_000)
    case scheme[%r{([A-Z,0-9]+)}, 1]
    when 'PBKDF2'
      salt = OpenSSL::Random.random_bytes(16)
      dk_len = 64

      derived_key = OpenSSL::PKCS5.pbkdf2_hmac(
        secret,
        salt,
        iterations,
        dk_len,
        OpenSSL::Digest::SHA512.new
      )

      value = [
        salt,
        iterations.to_s,
        derived_key
      ].join('$')

      password = "{PBKDF2-SHA512}#{Base64.strict_encode64(value)}"
    when 'CRYPT'
      salt = call_function('fqdn_rand_string', 2)
      password = "{CRYPT}#{secret.crypt(salt)}"
    when 'MD5'
      password = "{MD5}#{Digest::MD5.hexdigest(secret)}"
    when 'SMD5'
      salt = call_function('fqdn_rand_string', 8)
      md5_hash_with_salt = "#{Digest::MD5.digest(secret + salt)}#{salt}"
      password = "{SMD5}#{[md5_hash_with_salt].pack('m').delete("\n")}"
    when 'SSHA'
      salt = call_function('fqdn_rand_string', 8)
      password = "{SSHA}#{Base64.encode64("#{Digest::SHA1.digest(secret + salt)}#{salt}").chomp}"
    when 'SHA'
      password = "{SHA}#{Digest::SHA1.hexdigest(secret)}"
    else
      raise(Puppet::ParseError, "openldap_password(): Unrecognized scheme #{scheme}")
    end

    password
  end
end
