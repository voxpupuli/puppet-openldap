# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::overlay' do
  let(:title) { 'memberof on dc=example,dc=com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with ensure => present' do
        let(:params) do
          {
            ensure: 'present',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_openldap_overlay('memberof on dc=example,dc=com').
            with_ensure('present').
            with_overlay('memberof').
            with_suffix('dc=example,dc=com')
        }
      end

      context 'with options' do
        let(:params) do
          {
            ensure: 'present',
            options: [
              'olcMemberOfGroupOC: groupOfNames',
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_openldap_overlay('memberof on dc=example,dc=com').
            with_ensure('present').
            with_overlay('memberof').
            with_suffix('dc=example,dc=com').
            with_options(['olcMemberOfGroupOC: groupOfNames'])
        }
      end
    end
  end
end
