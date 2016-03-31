require 'digest/md5'

module Puppet
  module Puppet_X
    module Openldap
      class PwHash

        def self.hash_string(string, salt)
          # The pw_hash function doesn't work on all platforms. Using MD5
          # instead.
          #pw_hash(string, :sha256, salt.to_s)
          Digest::MD5.hexdigest("#{string}-#{salt.to_s}")
        end
      end
    end
  end
end
