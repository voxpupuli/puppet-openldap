require 'spec_helper_acceptance'

describe 'openldap::server::access define' do
  describe 'Add an ACL' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'openldap::server':
          databases => {
            'dc=foo,dc=example,dc=com' => {
              directory => '/var/lib/ldap/foo',
            },
          },
        }
        openldap::server::access { 'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=foo,dc=example,dc=com" on dc=foo,dc=example,dc=com':
	  access => 'write',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end

