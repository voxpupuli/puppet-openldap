require 'spec_helper_acceptance'

describe 'openldap::server::dbindex define' do

  describe 'Add a DB index' do
    after :all do
      apply_manifest("class { 'openldap::server': ensure => absent }", :catch_failures => true)
    end

    it 'should add a DB index' do
      pp = <<-EOS
        class { 'openldap::server':
          suffix => 'dc=foo,dc=example,dc=com',
        }
        openldap::server::dbindex { 'description on dc=foo,dc=example,dc=com':
          indices => 'eq',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end


