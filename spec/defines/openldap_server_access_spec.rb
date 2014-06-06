require 'spec_helper'

describe 'openldap::server::access' do

  let(:title) { 'foo' }

  let(:facts) {{
    :domain                    => 'example.com',
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  let :pre_condition do
    "class {'openldap::server':}"
  end

  context 'when Class[openldap::server] is not declared' do
    let(:pre_condition) { }
    it { expect { should compile }.to raise_error(Puppet::Error, /class ::openldap::server has not been evaluated/) }
  end

  context 'with composite namevar' do
    let(:title) {
     'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com'
    }
    it { should compile.with_all_deps }
    it {
      pending('Should work')
      should contain_openldap_access('to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com').that_requires('Openldap_database[dc=example,dc=com]')
    }
  end

end

