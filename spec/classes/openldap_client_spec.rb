require 'spec_helper'

describe 'openldap::client' do

  let(:facts) {{
    :osfamily => 'Debian',
  }}

  context 'with no parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('openldap::client').with({
      :package    => 'libldap-2.4-2',
      :file       => '/etc/ldap/ldap.conf',
      :base       => nil,
      :uri        => nil,
      :tls_cacert => nil,
    })}
    it { should contain_class('openldap::client::install') }
    it { should contain_class('openldap::client::config') }
  end

end

