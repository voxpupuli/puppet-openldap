require 'spec_helper'

describe 'openldap::server::access' do

  let(:title) { 'foo' }

  let(:facts) {{
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
     'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=ccmteam,dc=com" on dc=ccmteam,dc=com'
    }
    it { should compile.with_all_deps }
  end

end

