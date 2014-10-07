require 'spec_helper'

describe 'openldap::server::install' do

  let(:facts) {{
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'with no parameters' do
    let :pre_condition do
      "class {'openldap::server':}"
    end
    it { should compile.with_all_deps }
    it { should contain_class('openldap::server::install') }
    it { should contain_package('slapd').with({
      :ensure => :present,
    })}
  end

end
