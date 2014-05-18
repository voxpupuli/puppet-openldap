require 'spec_helper_acceptance'

describe 'openldap::server class' do

  describe 'without parameter' do
    it 'should install server' do
      pending('no domain and fqdn facts in vagrant box') {
        pp = <<-EOS
          class { 'openldap::server': }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      }
    end
  end

  describe 'when creating 1 database' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'openldap::server':
          databases => {
            'dc=foo,dc=example,dc=com' => {
              directory => '/var/lib/ldap',
            },
          },
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe 'when setting ensure to absent' do
    it 'should uninstall server' do
      pending('not implemented yet') {
        pp = <<-EOS
          class { 'openldap::server': ensure => absent }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      }
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
          default_database => 'dc=foo,dc=example,dc=com',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe 'when disabling service' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'enable => false:' do
      pp = <<-EOS
        class { 'openldap::server':
          enable    => false,
          databases => {
            'dc=foo,dc=bar' => {
              directory => '/var/lib/ldap',
            },
          },
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe 'when stopping service' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'start => false:' do
      pp = <<-EOS
        class { 'openldap::server':
          start     => false,
          databases => {
            'dc=foo,dc=bar' => {
              directory => '/var/lib/ldap',
            },
          },
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

end
