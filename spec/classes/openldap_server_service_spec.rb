require 'spec_helper'

describe 'openldap::server::service' do

  let(:facts) {{
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'with no parameters' do
    let :pre_condition do
      "class {'openldap::server':}"
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('openldap::server::service') }
    it { is_expected.to contain_service('slapd').with({
      :ensure => :running,
      :enable => true,
    })}
  end

end

