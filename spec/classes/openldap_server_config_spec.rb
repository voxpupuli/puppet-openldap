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
    it { should compile.with_all_deps }
    it { should contain_class('openldap::server::config') }
    it { should_not contain_openldap__globalconf( 'TLSCertificateFile') }
    it { should_not contain_openldap__globalconf( 'TLSCertificateKeyFile') }
    it { should_not contain_openldap__globalconf( 'TLSCACertificateFile') }
  end

end

