# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::install') }

        case facts[:osfamily]
        when 'Debian'
          it {
            is_expected.to contain_package('slapd').with(ensure: :installed)
          }
        when 'RedHat'
          it {
            is_expected.to contain_package('openldap-servers').with(ensure: :installed)
          }
        end

        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'].to_s == '9')
          it { is_expected.to contain_class('epel').that_comes_before('Package[openldap-servers]') }
        else
          it { is_expected.not_to contain_class('epel') }
        end

        context 'when manage_epel => false' do
          let(:pre_condition) do
            "class { 'openldap::server': manage_epel => false }"
          end

          it { is_expected.not_to contain_class('epel') } if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'].to_s == '9')
        end
      end

      context 'when overriding package name' do
        let :pre_condition do
          "class {'openldap::server': package => 'foo', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::install') }

        it {
          is_expected.to contain_package('foo').with(ensure: :installed)
        }
      end

      context 'when overriding package version' do
        let :pre_condition do
          "class {'openldap::server': package => 'bar', package_version => '2.4.6-1', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::install') }

        it {
          is_expected.to contain_package('bar').with(ensure: '2.4.6-1')
        }
      end
    end
  end
end
