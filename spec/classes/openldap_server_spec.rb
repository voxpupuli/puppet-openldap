require 'spec_helper'

describe 'openldap::server' do

  let(:facts) {{
    :domain                    => 'example.com',
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'with an unknown provider' do
    let :pre_condition do
      "class {'openldap::server': provider => 'foo'}"
    end

    it { expect { should compile }.to raise_error(Puppet::Error, /provider must be one of "olc" or "augeas"/) }
  end

  context 'with olc provider' do

    context 'with no parameters' do
      it { should compile.with_all_deps }
      it { should contain_class('openldap::server').with({
        :package  => 'slapd',
        :service  => 'slapd',
        :enable   => true,
        :start    => true,
        :provider => 'olc',
        :ssl_cert => nil,
        :ssl_key  => nil,
        :ssl_ca   => nil,
      })}
      it { should contain_class('openldap::server::install').
        that_comes_before('Class[openldap::server::config]') }
      it { should contain_class('openldap::server::config').
        that_notifies('Class[openldap::server::service]') }
      it { should contain_class('openldap::server::service').
        that_comes_before('Class[openldap::server::slapdconf]') }
      it { should contain_class('openldap::server::slapdconf').
        that_comes_before('Class[openldap::server]') }
      it { should have_openldap__server__database_resource_count(1) }
      it { should contain_openldap__server__database('dc=example,dc=com').with({
          :directory => '/var/lib/ldap',
        })
      }
    end
  end
end

