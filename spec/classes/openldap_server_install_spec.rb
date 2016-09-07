require 'spec_helper'

describe 'openldap::server::install' do

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
        it { is_expected.to contain_class('openldap::server::install') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('slapd').with({
            :ensure => :present,
          })}
        when 'RedHat'
          it { is_expected.to contain_package('openldap-servers').with({
            :ensure => :present,
          })}
        end
      end
    end
  end
end
