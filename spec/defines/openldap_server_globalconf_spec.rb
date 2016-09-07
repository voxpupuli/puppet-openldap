require 'spec_helper'

describe 'openldap::server::globalconf' do

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without value' do
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'with a value' do
        let(:params) {{ :value => 'bar' }}

        context 'with olc provider' do
          context 'with no parameters' do
            let :pre_condition do
              "class { 'openldap::server': }"
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_openldap__server__globalconf('foo').with({
              :value => 'bar',
            })}

          end
        end
      end
    end
  end
end
