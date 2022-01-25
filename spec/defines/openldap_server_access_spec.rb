# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::access' do
  let(:title) { '0 on dc=example,dc=com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with valid parameters' do
        let(:params) do
          {
            what: '*',
            access: [
              'by * read',
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_openldap_access('0 on dc=example,dc=com') }

        context 'with malformed namevar' do
          let(:title) do
            'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
          end

          it { is_expected.not_to compile.with_all_deps }
        end
      end

      context 'with access as an array' do
        let(:params) do
          {
            what: 'attrs=userPassword,shadowLastChange',
            access: [
              'by dn="cn=admin,dc=example,dc=com" write',
              'by anonymous read',
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_openldap_access('0 on dc=example,dc=com').
            with_what('attrs=userPassword,shadowLastChange').
            with_access(['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous read'])
        }
      end
    end
  end
end
