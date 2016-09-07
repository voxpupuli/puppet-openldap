require 'spec_helper'

describe 'openldap::server::database' do

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with an invalid directory' do
        let(:params) {{ :directory => 'bar' }}

        it { expect { is_expected.to compile }.to raise_error(/class ::openldap::server has not been evaluated/) }
      end

      context 'without declaring Class[openldap::server]' do
        let(:params) {{ :directory => '/foo/bar' }}

        it { expect { is_expected.to compile }.to raise_error(/class ::openldap::server has not been evaluated/) }
      end

      context 'with a valid directory' do
        let(:params) {{ :directory => '/foo/bar' }}

        context 'with olc provider' do

          context 'with no parameters' do
            let :pre_condition do
              "class { 'openldap::server': }"
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_openldap__server__database('foo').with({
              :directory => '/foo/bar',
            })}

          end
        end
      end
    end
  end
end
