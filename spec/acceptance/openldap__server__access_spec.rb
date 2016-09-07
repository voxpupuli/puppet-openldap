require 'spec_helper_acceptance'

describe 'openldap::server::access' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'openldap::server': }
        ::openldap::server::access { 'admin':
          what   => 'attrs=userPassword,shadowLastChange',
          by     => 'dn="cn=admin,dc=example,dc=com"',
          suffix => 'dc=example,dc=com',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end

