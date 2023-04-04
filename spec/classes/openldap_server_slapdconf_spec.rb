# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::slapdconf' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::server::slapdconf') }

        case facts[:osfamily]
        when 'RedHat'
          it { is_expected.to contain_openldap__server__database('dc=my-domain,dc=com').with(ensure: :absent) }
        else
          it { is_expected.not_to contain_openldap__server__database('dc=my-domain,dc=com').with(ensure: :absent) }
        end
      end
    end
  end
end
