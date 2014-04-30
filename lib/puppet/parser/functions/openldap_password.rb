module Puppet::Parser::Functions
  newfunction(:openldap_password, :type => :rvalue, :doc => <<-EOS
      Returns the openldap password hash from the clear text password.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "openldap_password(): Wrong number of arguments given") if args.size < 1 or args.size > 2

    secret = args[0]
    command = ['slappasswd', '-s', secret]
    scheme = args[1] if args[1]
    command << ['-h', scheme] if scheme

    Puppet::Util::Execution.execute(command.flatten).strip
  end
end
