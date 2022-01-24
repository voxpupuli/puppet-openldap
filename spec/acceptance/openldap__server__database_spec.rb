# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openldap::server::database' do
  context 'with syncrepl' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'openldap::server':
          databases => {
            'dc=foo,dc=example,dc=com' => {
              directory => '/var/lib/ldap',
              rootdn    => 'cn=admin,dc=foo,dc=example,dc=com',
              syncrepl => [
                'rid=1 provider=ldap://localhost searchbase="dc=foo,dc=example,dc=com"',
                'rid=2 provider=ldap://localhost searchbase="dc=foo,dc=example,dc=com"',
              ]
            }
          }
        }
      EOS

      idempotent_apply(pp)
    end
  end
end
