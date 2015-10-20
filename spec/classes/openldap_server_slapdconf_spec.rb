require 'spec_helper'

describe 'openldap::server::slapdconf' do

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
        it { is_expected.to contain_class('openldap::server::slapdconf') }
        it { is_expected.to contain_openldap__server__database('dc=my-domain,dc=com').with({:ensure => :absent,})}
      end

      # On rhel, openldap is linked against moz nss:
      # ssl_ca parameter should contain the path to the moz nss database
      # ssl_cert parameter should contain the name of the certificate stored into the moz nss database
      # ssl_key can be omitted/is not used
      context 'with ssl_cert and ssl_ca set but not ssl_key' do
        let :pre_condition do
          "class {'openldap::server': ssl_cert => 'my-domain.com', ssl_ca => '/etc/openldap/certs'}"
        end
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_class('openldap::server::slapdconf') }
          it { expect { is_expected.to compile }.to raise_error(/You must specify a ssl_key/) }
        when 'RedHat'
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::server::slapdconf') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCertificateFile') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCACertificateFile') }
          it { is_expected.not_to contain_openldap__server___globalconf( 'TLSCertificateKeyFile') }
        end
      end

      context 'with ssl_cert, ssl_key and ssl_ca set' do
        let :pre_condition do
          "class {'openldap::server': ssl_cert => '/etc/openldap/certs/fqdn.tld.crt', ssl_key => '/etc/openldap/certs/fqdn.tld.key', ssl_ca => '/etc/openldap/certs/ca.crt'}"
        end
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::server::slapdconf') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCertificateFile') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCACertificateFile') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCertificateKeyFile') }
        when 'RedHat'
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::server::slapdconf') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCertificateFile') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCACertificateFile') }
          it { is_expected.to contain_openldap__server__globalconf( 'TLSCertificateKeyFile') }
        end
      end
    end
  end
end
