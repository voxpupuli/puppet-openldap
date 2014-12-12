require 'spec_helper'

describe 'openldap::server::slapdconf' do

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
        it { is_expected.to contain_class('openldap::server::slapdconf') }
        it { is_expected.to contain_openldap__server__database('dc=my-domain,dc=com').with({:ensure => :absent,})}
      end
    end
  end
end
