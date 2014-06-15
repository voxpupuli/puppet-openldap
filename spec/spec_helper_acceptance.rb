require 'beaker-rspec'

hosts.each do |host|
  # Hack /etc/hosts so that fact fqdn works
  on host, "sed -i 's/^#{host['ip'].to_s}\t#{host[:vmhostname] || host.name}$/#{host['ip'].to_s}\t#{host[:vmhostname] || host.name}.example.com #{host[:vmhostname] || host.name}/' /etc/hosts"
  # Install Ruby
  install_package host, 'ruby'
  # Install Puppet
  on host, "ruby --version | cut -f2 -d ' ' | cut -f1 -d 'p'" do |version|
    version = version.stdout.strip
    if Gem::Version.new(version) < Gem::Version.new('1.9')
      install_package host, 'rubygems'
    end
  end
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
  # Install ruby-augeas
  case fact('osfamily')
  when 'Debian'
    install_package host, 'libaugeas-ruby'
  when 'RedHat'
    install_package host, 'ruby-devel'
    install_package host, 'augeas-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'openldap')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','domcleal-augeasproviders'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
