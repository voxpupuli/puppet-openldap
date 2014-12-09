require 'spec_helper'

describe 'openldap::server::module' do

  let(:title) { 'foo' }

  on_puppet_supported_platforms.each do |version, platforms|
    platforms.each do |platform, facts|
      context "on #{version} #{platform}" do
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
end
