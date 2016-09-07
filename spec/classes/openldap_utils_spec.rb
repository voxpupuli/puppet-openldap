require 'spec_helper'

describe 'openldap::utils' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('ldap-utils').with({
            :ensure => :present,
          })
          }
        when 'RedHat'
          it { is_expected.to contain_package('openldap-clients').with({
            :ensure => :present,
          })
          }
        end
      end

      context 'when overriding package name' do
        let :pre_condition do
          "class {'openldap::utils': package => 'foo', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('foo').with({
          :ensure => :present,
        })
        }
      end
    end
  end
end
