require 'beaker-rspec'

def ldapsearch(cmd, exit_codes = [0,1], &block)
  shell("ldapsearch #{cmd}", :acceptable_exit_codes => exit_codes, &block)
end

hosts.each do |host|
  # Install Puppet
  install_puppet()
  # Install ruby-augeas
  case fact('osfamily')
  when 'Debian'
    # Fix for beaker on Docker
    on host, 'rm /usr/sbin/policy-rc.d || true'
    if fact('operatingsystemmajrelease').to_i < 7
      on host, 'echo deb http://httpredir.debian.org/debian-backports squeeze-backports main >> /etc/apt/sources.list'
      on host, 'apt-get update'
      on host, 'apt-get -y -t squeeze-backports install libaugeas0 augeas-lenses'
    end
    install_package host, 'libaugeas-ruby'
  when 'RedHat'
    on host, 'setenforce 0' if fact('selinux') == 'true'
    install_package host, 'gcc'
    install_package host, 'ruby-devel'
    install_package host, 'augeas-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
  install_package host, 'net-tools'
end

RSpec.configure do |c|
  # Project root
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('-').last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => module_root, :module_name => module_name)
    hosts.each do |host|
      on host, puppet('module','install','herculesteam-augeasproviders_core'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_shellvar'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
