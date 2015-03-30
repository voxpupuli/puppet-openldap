module Puppet::Parser::Functions
  newfunction(:openldap_password, :type => :rvalue, :doc => <<-EOS
    Returns the openldap password hash from the clear text password.
  EOS
  ) do |args|

    raise(Puppet::ParseError, "openldap_password(): Wrong number of arguments given") if args.size < 1 or args.size > 2

    password = args[0]
    salt = Digest::SHA1.digest(lookupvar('::fqdn'))[0..4]

    "{SSHA}" + Base64.encode64("#{Digest::SHA1.digest("#{password}#{salt}")}#{salt}").chomp
  end
end
