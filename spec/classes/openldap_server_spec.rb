require 'spec_helper'

describe 'openldap::server' do

  context 'on RedHat4' do
    let(:facts) {{
      :domain                    => 'example.com',
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => 4,
      :openldap_server_version   => '2.2.13',
    }}

    context 'with no parameters' do
      it { should compile.with_all_deps }
      it { should contain_class('openldap::server').with({
        :package  => 'openldap-servers',
        :service  => 'ldap',
        :enable   => true,
        :start    => true,
        :provider => 'augeas',
        :ssl      => false,
        :ssl_cert => nil,
        :ssl_key  => nil,
        :ssl_ca   => nil,
      })}
      it { should contain_class('openldap::server::install')
        .that_comes_before('Class[openldap::server::config]') }
      it { should contain_class('openldap::server::config')
        .that_notifies('Class[openldap::server::service]') }
      it { should contain_class('openldap::server::service')
        .that_comes_before('Class[openldap::server]')
      }
#      it { should have_openldap__server__database_resource_count(1) }
#      it { should contain_openldap__server__database('dc=example,dc=com')
#        .with({
#          :directory => '/var/lib/ldap',
#        })
#      }
    end
  end

  context 'on Debian7' do
    let(:facts) {{
      :domain                    => 'example.com',
      :osfamily                  => 'Debian',
      :openldap_server_version   => '2.4.31',
    }}

    context 'with no parameters' do
      it { should compile.with_all_deps }
      it { should contain_class('openldap::server').with({
        :package  => 'slapd',
        :service  => 'slapd',
        :enable   => true,
        :provider => 'olc',
        :start    => true,
        :ssl      => false,
        :ssl_cert => nil,
        :ssl_key  => nil,
        :ssl_ca   => nil,
      })}
      it { should contain_class('openldap::server::install')
        .that_comes_before('Class[openldap::server::config]') }
      it { should contain_class('openldap::server::config')
        .that_notifies('Class[openldap::server::service]') }
      it { should contain_class('openldap::server::service')
        .that_comes_before('Class[openldap::server]')
      }
#      it { should have_openldap__server__database_resource_count(1) }
#      it { should contain_openldap__server__database('dc=example,dc=com')
#        .with({
#          :directory => '/var/lib/ldap',
#        })
#      }
    end
  end
end

