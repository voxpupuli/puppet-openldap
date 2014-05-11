require 'spec_helper_acceptance'

describe 'openldap::server class' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'openldap::server':
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
