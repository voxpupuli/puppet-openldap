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
    if fact('operatingsystem') == 'Debian' and fact('operatingsystemmajrelease').to_i < 7
      on host, 'echo deb http://httpredir.debian.org/debian-backports squeeze-backports main >> /etc/apt/sources.list'
      on host, 'apt-get update'
      on host, 'apt-get -y -t squeeze-backports install libaugeas0 augeas-lenses'
    end
    install_package host, 'libaugeas-ruby'
  when 'RedHat'
    on host, 'setenforce 0' if fact('selinux') == 'true'
    install_package host, 'make'
    install_package host, 'gcc'
    install_package host, 'ruby-devel'
    install_package host, 'augeas-devel'
    install_package host, 'initscripts' # FIXME: openldap_database's olc provider's create method should call systemctl when using systemd
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
  on host, 'puppet cert generate $(facter fqdn)'
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

    # Set up Certificates
    pp = <<-EOS
      $ssldir = '/var/lib/puppet/ssl'
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
          path    => $::path,
          require => File['/etc/ldap/ssl'],
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
