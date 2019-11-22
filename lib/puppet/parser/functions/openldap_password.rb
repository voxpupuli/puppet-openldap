require 'base64'

module Puppet::Parser::Functions
  newfunction(:openldap_password, :type => :rvalue, :doc => <<-EOS
      Returns the openldap password hash from the clear text password.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "openldap_password(): Wrong number of arguments given") if args.size < 1 or args.size > 2

    secret = args[0]
    scheme = args[1] || '{SSHA}'

    Puppet::Parser::Functions.function('fqdn_rand_string')

    case scheme[/([A-Z,0-9]+)/, 1]
    when 'CRYPT'
      salt = function_fqdn_rand_string([2])
      password = '{CRYPT}' + secret.crypt(salt)
    when 'MD5'
      password = '{MD5}' + Digest::MD5.hexdigest(secret)
    when 'SMD5'
      salt = function_fqdn_rand_string([8])
      md5_hash_with_salt = "#{Digest::MD5.digest(secret + salt)}#{salt}"
      password = '{SMD5}' + [md5_hash_with_salt].pack('m').gsub("\n", '')
    when 'SSHA'
      salt = function_fqdn_rand_string([8])
      password = '{SSHA}' + Base64.encode64("#{Digest::SHA1.digest(secret + salt)}#{salt}").chomp
    when 'SHA'
      password = '{SHA}' + Digest::SHA1.hexdigest(secret)
    else
      raise(Puppet::ParseError, "openldap_password(): Unrecognized scheme #{scheme}")
    end

    password
  end
end
