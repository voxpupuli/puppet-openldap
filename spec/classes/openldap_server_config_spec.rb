require 'spec_helper'

describe 'openldap::server::config' do

  let(:facts) {{
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'with no parameters' do
    let :pre_condition do
      "class {'openldap::server':}"
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('openldap::server::config') }
    it { is_expected.not_to contain_openldap__globalconf( 'TLSCertificateFile') }
    it { is_expected.not_to contain_openldap__globalconf( 'TLSCertificateKeyFile') }
    it { is_expected.not_to contain_openldap__globalconf( 'TLSCACertificateFile') }
  end

end

