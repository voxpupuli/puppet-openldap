require 'spec_helper'

describe 'openldap::server::module' do

  let(:title) { 'foo' }

  let(:facts) {{
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'without declaring Class[openldap::server]' do
    it { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context 'without parameter' do
    let :pre_condition do
      "class { 'openldap::server': }"
    end

    it { should compile.with_all_deps }
  end

 end

