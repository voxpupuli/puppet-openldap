require 'spec_helper_acceptance'

describe 'openldap::server::access' do

  before :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=example,dc=com':
        ensure => absent,
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  after :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=example,dc=com': ensure => absent, }
    EOS

    apply_manifest(pp, :expect_changes => true)
    apply_manifest(pp, :catch_changes => true)
  end

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { '::openldap::server': }

        # This may be needed for the access rule below to work
        ::openldap::server::schema { ['cosine', 'inetorgperson', 'nis']:
          ensure => present,
        }

        ::openldap::server::database { 'dc=example,dc=com' : }

        ::openldap::server::access { 'admin':
          what     => 'attrs=userPassword,shadowLastChange',
          access   => ['by dn="cn=admin,dc=example,dc=com" write'],
          suffix   => 'dc=example,dc=com',
          require  => Openldap::Server::Database['dc=example,dc=com'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
      #apply_manifest(pp, :catch_failures => true, :trace => true, :debug => true)
      #apply_manifest(pp, :catch_changes => true, :trace => true, :debug => true)
    end
  end

end

