# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::access_wrapper' do
  let(:title) { 'dc=example,dc=com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          acl: [
            {
              'to *' => [
                'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
                'by dn.exact=cn=admin,dc=example,dc=com write',
                'by dn.exact=cn=replicator,dc=example,dc=com read',
                'by * break',
              ],
            },
            {
              'to attrs=userPassword,shadowLastChange' => [
                'by dn="cn=admin,dc=example,dc=com" write',
                'by self write',
                'by anonymous auth',
              ],
            },
            {
              'to *' => [
                'by self read',
              ],
            },
          ],
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_openldap__server__access_resource_count(3) }

      it do
        is_expected.to contain_openldap_access('0 on dc=example,dc=com').with(
          position: 0,
          what: '*',
          access: [
            'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
            'by dn.exact=cn=admin,dc=example,dc=com write',
            'by dn.exact=cn=replicator,dc=example,dc=com read',
            'by * break',
          ],
          suffix: 'dc=example,dc=com'
        )
      end

      it do
        is_expected.to contain_openldap_access('1 on dc=example,dc=com').with(
          position: 1,
          what: 'attrs=userPassword,shadowLastChange',
          access: [
            'by dn="cn=admin,dc=example,dc=com" write',
            'by self write',
            'by anonymous auth',
          ],
          suffix: 'dc=example,dc=com'
        )
      end

      it do
        is_expected.to contain_openldap_access('2 on dc=example,dc=com').with(
          position: 2,
          what: '*',
          access: [
            'by self read',
          ],
          suffix: 'dc=example,dc=com'
        )
      end
    end
  end
end
