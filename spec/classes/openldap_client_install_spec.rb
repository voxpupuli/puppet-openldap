require 'spec_helper'

describe 'openldap::client::install' do

  let :pre_condition do
    "class {'openldap::client':}"
  end

  let(:facts) {{
    :osfamily => 'Debian',
  }}

  context 'with no parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('openldap::client::install') }
    it { should contain_package('libldap-2.4-2').with({
      :ensure => :present,
    })}
  end

end

