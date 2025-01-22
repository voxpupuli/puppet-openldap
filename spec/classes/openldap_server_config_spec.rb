# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::config') }
        it { is_expected.not_to contain_openldap__globalconf('TLSCertificateFile') }
        it { is_expected.not_to contain_openldap__globalconf('TLSCertificateKeyFile') }
        it { is_expected.not_to contain_openldap__globalconf('TLSCACertificateFile') }

        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'].to_i >= 8)
          it { is_expected.to contain_systemd__dropin_file('puppet.conf') }
        else
          it { is_expected.not_to contain_systemd__dropin_file('puppet.conf') }
        end
      end
    end

    next if facts[:os]['family'] != 'Debian'

    context "on #{os} with KRB5 conf" do
      let(:facts) do
        facts
      end

      let(:pre_condition) do
        "class {'openldap::server': krb5_client_keytab_file => '/etc/krb5.keytab', }"
      end

      context 'with /etc/krb5.keytab' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::config') }
        it { is_expected.to contain_shellvar('krb5_client_ktname').with(value: '/etc/krb5.keytab') }
      end
    end

    context "on #{os} with nonstandard package" do
      let(:facts) do
        facts
      end

      let(:pre_condition) do
        "class {'openldap::server': package => 'some-openldap-clone', }"
      end

      context 'with some-openldap-clone' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::config') }
        it { is_expected.not_to contain_systemd__dropin_file('puppet.conf') }
      end
    end
  end
end
