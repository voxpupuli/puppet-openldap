# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::globalconf' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without value' do
        it { is_expected.not_to compile }
      end

      context 'with a value' do
        let(:params) { { value: 'bar' } }

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_openldap_global_conf('foo').with(value: 'bar')
        }
      end
    end
  end
end
