require 'spec_helper'

describe 'openldap::server::database' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with a valid directory' do
        let(:params) { { directory: '/foo/bar' } }

        context 'with olc provider' do
          context 'with no parameters' do
            it { is_expected.to compile.with_all_deps }
            it {
              is_expected.to contain_openldap__server__database('foo').with(directory: '/foo/bar')
            }
          end
        end
      end
    end
  end
end
