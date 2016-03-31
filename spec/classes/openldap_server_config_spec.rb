require 'spec_helper'

describe 'openldap::server::config' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        let :pre_condition do
          "class {'openldap::server':}"
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::config') }

	# XXX: In the current setup, this will never be contained. This is why
	#      I did not rename the __globalconf to __config_hash as well.
        # TODO: Find a way to check this properly.
        it { is_expected.not_to contain_openldap__globalconf( 'TLSCertificateFile') }
        it { is_expected.not_to contain_openldap__globalconf( 'TLSCertificateKeyFile') }
        it { is_expected.not_to contain_openldap__globalconf( 'TLSCACertificateFile') }
      end
    end
  end
end
