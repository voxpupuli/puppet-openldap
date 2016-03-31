module Puppet::Parser::Functions
  newfunction(
    :openldap_password,
    :type  => :rvalue,
    :arity => -2,
    :doc   => <<-EOS
      Returns the openldap password hash from the clear text password.
    EOS
  ) do |args|

    secret  = args[0]
    command = ['slappasswd', '-s', secret]
    scheme  = args[1] if args[1]
    command << ['-h', scheme] if scheme

    Puppet::Util::Execution.execute(command.flatten).strip
  end
end
