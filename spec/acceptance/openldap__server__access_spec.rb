# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openldap::server::access' do
  before :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=example,dc=com':
        ensure => absent,
      }
    EOS

    idempotent_apply(pp)
  end

  after :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=example,dc=com':
        ensure => absent,
      }
    EOS

    idempotent_apply(pp)
  end

  context 'with defaults' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'openldap::server': }
        openldap::server::database { 'dc=example,dc=com' : }
        openldap::server::access { '0 on dc=example,dc=com':
          what    => 'attrs=userPassword,distinguishedName',
          access  => ['by dn="cn=admin,dc=example,dc=com" write'],
          require => Openldap::Server::Database['dc=example,dc=com'],
        }
        openldap::server::access { '1 on dc=example,dc=com':
          what    => '*',
          access  => [
            'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
            'by * break'
          ],
          require => Openldap::Server::Database['dc=example,dc=com'],
        }
      EOS

      idempotent_apply(pp)
    end
  end
end
