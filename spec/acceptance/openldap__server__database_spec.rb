require 'spec_helper_acceptance'

describe 'openldap::server::database define' do
  describe 'creating a database' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'should work with no errors' do
      pp = <<-EOS
        class { 'openldap::server':
          suffix => 'dc=foo,dc=example,dc=com',
        }
        openldap::server::database { 'dc=bar,dc=example,dc=com':
          directory => '/var/lib/ldap/bar',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
