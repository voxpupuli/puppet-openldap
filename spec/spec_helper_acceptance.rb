require 'beaker-rspec'

def ldapsearch(cmd, exit_codes = [0,1], &block)
  shell("ldapsearch #{cmd}", :acceptable_exit_codes => exit_codes, &block)
end

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

    # Set up Certificates
    pp = <<-EOS
      $ssldir = '/etc/puppet/ssl'
      Exec {
        path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
      exec { "puppet cert generate ${::fqdn}":
        creates => [
          "${ssldir}/private_keys/${::fqdn}.pem",
          "${ssldir}/certs/${::fqdn}.pem",
        ],
      }
      file { '/etc/ldap':
        ensure => directory,
      }
      file { '/etc/ldap/ssl':
        ensure => directory,
      }
      if $::osfamily == 'Debian' {
        # OpenLDAP is linked towards GnuTLS on Debian so we have to convert the key
        package { 'gnutls-bin':
          ensure => present,
        }
        ->
        exec { "certtool -k < ${ssldir}/private_keys/${::fqdn}.pem > /etc/ldap/ssl/${::fqdn}.key":
          creates => "/etc/ldap/ssl/${::fqdn}.key",
          require => [
            File['/etc/ldap/ssl'],
            Exec["puppet cert generate ${::fqdn}"],
          ],
          before  => File["/etc/ldap/ssl/${::fqdn}.key"],
        }
      } else {
        File <| title == "/etc/ldap/ssl/${::fqdn}.key" |> {
          source => "${ssldir}/private_keys/${::fqdn}.pem",
        }
      }
      file { "/etc/ldap/ssl/${::fqdn}.key":
        ensure  => file,
        mode    => '0644',
      }
      file { "/etc/ldap/ssl/${::fqdn}.crt":
        ensure  => file,
        mode    => '0644',
        source  => "${ssldir}/certs/${::fqdn}.pem",
      }
      file { '/etc/ldap/ssl/ca.pem':
        ensure  => file,
        mode    => '0644',
        source  => "${ssldir}/certs/ca.pem",
      }
    EOS

    apply_manifest_on(hosts, pp, :catch_failures => false)

    hosts.each do |host|
      on host, puppet('module','install','herculesteam-augeasproviders_core'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_shellvar'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
