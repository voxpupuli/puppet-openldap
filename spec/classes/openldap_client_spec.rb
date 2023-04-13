# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::install').that_comes_before('Class[openldap::client::config]') }

        case facts[:osfamily]
        when 'Debian'
          case facts[:os]['release']['major']
          when '22.04'
            it {
              is_expected.to contain_class('openldap::client').with(package: 'libldap-2.5-0',
                                                                    file: '/etc/ldap/ldap.conf',
                                                                    base: nil,
                                                                    uri: nil,
                                                                    tls_cacert: nil)
            }
          else
            it {
              is_expected.to contain_class('openldap::client').with(package: 'libldap-2.4-2',
                                                                    file: '/etc/ldap/ldap.conf',
                                                                    base: nil,
                                                                    uri: nil,
                                                                    tls_cacert: nil)
            }
          end
        when 'RedHat'
          it {
            is_expected.to contain_class('openldap::client').with(package: 'openldap',
                                                                  file: '/etc/openldap/ldap.conf',
                                                                  base: nil,
                                                                  uri: nil,
                                                                  tls_cacert: nil)
          }
        end
      end
    end
  end
end
