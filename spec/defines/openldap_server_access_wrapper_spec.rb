require 'spec_helper'

describe 'openldap::server::access_wrapper' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          acl: {
            '0 to *' => [
              'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
              'by dn.exact=cn=admin,dc=example,dc=com write',
              'by dn.exact=cn=replicator,dc=example,dc=com read',
              'by * break',
            ],
            '1 to attrs=userPassword,shadowLastChange' => [
              'by dn="cn=admin,dc=example,dc=com" write',
              'by self write',
              'by anonymous auth',
            ],
            '2 to *' => [
              'by self read',
            ],
          }
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_openldap__server__access_resource_count(3) }
    end
  end
end
