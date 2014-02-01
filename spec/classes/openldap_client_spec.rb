require 'spec_helper'

describe 'openldap::client' do

  context 'on Debian' do
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
        })
      }
      it { should contain_class('openldap::client::install').that_comes_before('Class[openldap::client::config]') }
      it { should contain_class('openldap::client::config').that_comes_before('Class[openldap::client]') }
    end
  end

  context 'on RedHat' do
    let(:facts) {{
      :osfamily => 'RedHat',
    }}

    context 'with no parameters' do
      it { should compile.with_all_deps }
      it { should contain_class('openldap::client').with({
          :package    => 'openldap',
          :file       => '/etc/openldap/ldap.conf',
          :base       => nil,
          :uri        => nil,
          :tls_cacert => nil,
        })
      }
      it { should contain_class('openldap::client::install').that_comes_before('Class[openldap::client::config]') }
      it { should contain_class('openldap::client::config').that_comes_before('Class[openldap::client]') }
    end
  end

end

