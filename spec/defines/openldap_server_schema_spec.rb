require 'spec_helper'

describe 'openldap::server::schema' do

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without declaring Class[openldap::server]' do
        it { expect { is_expected.to compile }.to raise_error(/::openldap::server has not been evaluated/) }
      end

      context 'without parameter' do
        let :pre_condition do
          "class { 'openldap::server': }"
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
