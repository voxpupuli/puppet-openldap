require 'spec_helper'

describe 'openldap::server::access' do

  let(:title) { 'foo' }

  let :pre_condition do
    "class {'openldap::server':}"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'when Class[openldap::server] is not declared' do
        let(:pre_condition) { }
        it { expect { is_expected.to compile }.to raise_error(/class ::openldap::server has not been evaluated/) }
      end

    end
  end
end
