require 'spec_helper_acceptance'

describe 'openldap::server class' do

  describe 'without parameter' do
    it 'should install server' do
      pp = <<-EOS
        class { 'openldap::server': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

  describe 'when setting ensure to absent' do
    it 'should uninstall server' do
      pp = <<-EOS
        class { 'openldap::server':
          ensure => absent,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/etc/ldap/slapd.d') do
      it { should_not be_directory }
    end

    describe file('/etc/ldap/slapd.conf') do
      it { should_not be_file }
    end

    describe file('/etc/openldap/slapd.d') do
      it { should_not be_directory }
    end

    describe file('/etc/openldap/slapd.conf') do
      it { should_not be_file }
    end

    describe port(389) do
      it { should_not be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

  describe 'with SSL' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'should install server' do
      pp = <<-EOS
        $owner     = $::osfamily ? {
          Debian => 'openldap',
          RedHat => 'ldap',
        }
        $group     = $::osfamily ? {
          Debian => 'openldap',
          RedHat => 'ldap',
        }
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
          owner   => $owner,
          group   => $group,
          mode    => '0600',
          require => Class['openldap::server::install'],
          before  => Class['openldap::server::slapdconf'],
        }
        file { "/etc/ldap/ssl/${::fqdn}.crt":
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => '0644',
          source  => "${ssldir}/certs/${::fqdn}.pem",
          require => Class['openldap::server::install'],
          before  => Class['openldap::server::slapdconf'],
        }
        file { '/etc/ldap/ssl/ca.pem':
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => '0644',
          source  => "${ssldir}/certs/ca.pem",
          require => Class['openldap::server::install'],
          before  => Class['openldap::server::slapdconf'],
        }
        class { '::openldap::server':
          ldaps_ifs => ['/'],
          ssl_key   => "/etc/ldap/ssl/${::fqdn}.key",
          ssl_cert  => "/etc/ldap/ssl/${::fqdn}.crt",
          ssl_ca    => '/etc/ldap/ssl/ca.pem',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should be_listening }
    end

    describe port(636) do
      it { should be_listening }
    end

  end

  describe 'when creating 1 database' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'should install server with specified suffix' do
      pp = <<-EOS
        class { 'openldap::server':
          suffix => 'dc=foo,dc=example,dc=com',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

  describe 'when creating 2 databases' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'should create 2 databases' do
      pp = <<-EOS
        class { 'openldap::server':
          databases        => {
            'dc=foo,dc=example,dc=com' => {
              directory => '/var/lib/ldap/foo',
            },
            'dc=bar,dc=example,dc=com' => {
              directory => '/var/lib/ldap/bar',
            },
          },
          suffix => 'dc=foo,dc=example,dc=com',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

  describe 'when disabling service' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'enable => false:' do
      pp = <<-EOS
        class { 'openldap::server':
          enable => false,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

  describe 'when stopping service' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'start => false:' do
      pp = <<-EOS
        class { 'openldap::server':
          start  => false,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(389) do
      it { should_not be_listening }
    end

    describe port(636) do
      it { should_not be_listening }
    end

  end

end
