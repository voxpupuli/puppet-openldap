require 'spec_helper_acceptance'

describe 'openldap::server::dbindex' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'openldap::server':
          databases => {
            'dc=foo,dc=example,dc=com' => {
              directory => '/var/lib/ldap',
              rootdn    => 'cn=admin,dc=foo,dc=example,dc=com',
            }
          }
        }
        Openldap::Server::Dbindex {
          suffix => 'dc=foo,dc=example,dc=com',
        }
        ::openldap::server::dbindex {
          'cn':
            attribute => 'cn',
            indices   => 'pres,sub,eq';
          'uid':
            attribute => 'uid',
            indices   => 'pres,sub,eq';
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
