require 'spec_helper'

describe 'openldap::client::config' do

  let :pre_condition do
    "class {'openldap::client':}"
  end

  let(:facts) {{
    :osfamily => 'Debian',
  }}

  context 'with no parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('openldap::client::config') }
    it { should contain_file('/etc/ldap/ldap.conf') }
  end

end

