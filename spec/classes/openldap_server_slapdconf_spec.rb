require 'spec_helper'

describe 'openldap::server::slapdconf' do

  context 'on Debian' do

    let(:facts) {{
      :domain                    => 'example.com',
      :osfamily                  => 'Debian',
      :operatingsystemmajrelease => '7',
    }}
  
    context 'with no parameters' do
      let :pre_condition do
        "class {'openldap::server':}"
      end
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('openldap::server::slapdconf') }
      it { is_expected.to contain_openldap__server__database('dc=my-domain,dc=com').with({:ensure => :absent,})}
    end

  end

  context 'on RedHat' do

    let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '6',
    }}
  
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


