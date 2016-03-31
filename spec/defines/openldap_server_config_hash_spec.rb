require 'spec_helper'

describe 'openldap::server::config_hash' do

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without value' do
        it { expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError) }
      end

      context 'with a string value' do
        let(:params) {{ :value => 'bar' }}

        it { expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError) }
      end

      context 'with a hash value' do
        let(:params) {{ :value => {
          'LogLevel' => 'foo'
	} }}
        context 'with olc provider' do
          context 'with no parameters' do
            let :pre_condition do
              "class { 'openldap::server': }"
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_openldap__server__config_hash('foo').with({
              :value => {
                'LogLevel' => 'foo'
              }
            })}

          end
        end
      end
    end
  end
end
