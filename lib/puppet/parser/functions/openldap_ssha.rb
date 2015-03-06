require 'digest/sha1'
require 'base64'

module Puppet::Parser::Functions
  newfunction(:openldap_ssha, :type => :rvalue) do |args|
    "{SSHA}"+Base64.encode64(Digest::SHA1.digest(args[0]+'salt')+'salt').chomp!    
  end
end
