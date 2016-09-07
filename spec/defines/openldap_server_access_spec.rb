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

      context 'with composite namevar' do
        let(:title) {
          'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
        }
        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_openldap_access('to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com')
        }
      end

      context 'with composite namevar, what includes dn and filter' do
        let(:title) {
          'to dn.one="ou=users,dc=example,dc=com" filter=(objectClass=person) by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
        }
        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_openldap_access('to dn.one="ou=users,dc=example,dc=com" filter=(objectClass=person) by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com')
        }
      end

      context 'with composite namevar, what includes dn and attrs' do
        let(:title) {
          'to dn.one="ou=users,dc=example,dc=com" attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
        }
        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_openldap_access('to dn.one="ou=users,dc=example,dc=com" attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com')
        }
      end

      context 'with composite namevar, what includes dn, filter and attrs' do
        let(:title) {
          'to dn.one="ou=users,dc=example,dc=com" filter=(objectClass=person) attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
        }
        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_openldap_access('to dn.one="ou=users,dc=example,dc=com" filter=(objectClass=person) attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com')
        }
      end
    end
  end
end
