require 'beaker-rspec'

def ldapsearch(cmd, exit_codes = [0,1], &block)
  shell("ldapsearch #{cmd}", :acceptable_exit_codes => exit_codes, &block)
end

install_puppet_agent_on hosts, {}

hosts.each do |host|
  if fact('osfamily') == 'RedHat'
    install_package host, 'initscripts' # FIXME: openldap_database's olc provider's create method should call systemctl when using systemd
  end
  on host, 'puppet cert generate $(facter fqdn)'
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
      $ssldir = '/etc/puppetlabs/puppet/ssl'
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
