# frozen_string_literal: true

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
          it {
            is_expected.to contain_package('ldap-utils').with(ensure: :installed)
          }
        when 'RedHat'
          it {
            is_expected.to contain_package('openldap-clients').with(ensure: :installed)
          }
        end
      end

      context 'when overriding package name' do
        let :pre_condition do
          "class {'openldap::utils': package => 'foo', }"
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('foo').with(ensure: :installed)
        }
      end

      context 'when overriding package version' do
        let :pre_condition do
          "class {'openldap::utils': package => 'bar', package_version => '3.6.9-12', }"
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('bar').with(ensure: '3.6.9-12')
        }
      end
    end
  end
end
