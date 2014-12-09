require 'spec_helper'

describe 'openldap::client::config' do

  on_puppet_supported_platforms.each do |version, platforms|
    platforms.each do |platform, facts|
      context "on #{version} #{platform}" do
        let(:facts) do
          facts
        end

        context 'with no parameters' do
          let :pre_condition do
            "class {'openldap::client':}"
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::client::config') }
          it { is_expected.not_to contain_augeas('ldap.conf+base') }
          it { is_expected.not_to contain_augeas('ldap.conf+uri') }
          it { is_expected.not_to contain_augeas('ldap.conf+cacert') }
        end

        context 'with base set' do
          let :pre_condition do
            "class {'openldap::client': base => 'dc=example,dc=com', }"
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::client::config') }
          it { is_expected.to contain_augeas('ldap.conf+base').with({
            :incl    => '/etc/ldap/ldap.conf',
            :context => '/files/etc/ldap/ldap.conf',
            :changes => 'set BASE dc=example,dc=com',
          })
          }
          it { is_expected.not_to contain_augeas('ldap.conf+uri') }
          it { is_expected.not_to contain_augeas('ldap.conf+tls_cacert') }
        end

        context 'with uri set' do
          let :pre_condition do
            "class {'openldap::client': uri => 'ldap://ldap.example.com', }"
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::client::config') }
          it { is_expected.not_to contain_augeas('ldap.conf+base') }
          it { is_expected.to contain_augeas('ldap.conf+uri').with({
            :incl    => '/etc/ldap/ldap.conf',
            :context => '/files/etc/ldap/ldap.conf',
            :changes => "set URI 'ldap://ldap.example.com'",
          })
          }
          it { is_expected.not_to contain_augeas('ldap.conf+tls_cacert') }
        end

        context 'with multiple uri set' do
          let :pre_condition do
            "class {'openldap::client': uri => ['ldap://ldap1.example.com', 'ldap://ldap2.example.com'] }"
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::client::config') }
          it { is_expected.not_to contain_augeas('ldap.conf+base') }
          it { is_expected.to contain_augeas('ldap.conf+uri').with({
            :incl    => '/etc/ldap/ldap.conf',
            :context => '/files/etc/ldap/ldap.conf',
            :changes => "set URI 'ldap://ldap1.example.com ldap://ldap2.example.com'",
          })
          }
          it { is_expected.not_to contain_augeas('ldap.conf+tls_cacert') }
        end

        context 'with an invalid tls_cacert set' do
          let :pre_condition do
            "class {'openldap::client': tls_cacert => 'foo', }"
          end

          it { expect { is_expected.to compile }.to raise_error(/\"foo\" is not an absolute path/) }
        end

        context 'with a valid tls_cacert set' do
          let :pre_condition do
            "class {'openldap::client': tls_cacert => '/etc/ssl/certs/ca-certificates.crt', }"
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openldap::client::config') }
          it { is_expected.not_to contain_augeas('ldap.conf+base') }
          it { is_expected.not_to contain_augeas('ldap.conf+uri') }
          it { is_expected.to contain_augeas('ldap.conf+tls_cacert').with({
            :incl    => '/etc/ldap/ldap.conf',
            :context => '/files/etc/ldap/ldap.conf',
            :changes => 'set TLS_CACERT /etc/ssl/certs/ca-certificates.crt',
          })
          }
        end
      end
    end
  end
end
