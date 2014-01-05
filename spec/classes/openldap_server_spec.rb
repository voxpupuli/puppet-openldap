require 'spec_helper'

describe 'openldap::server' do

  let(:facts) {{
    :osfamily => 'Debian',
  }}

  context 'with no parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('openldap::server').with({
      :package  => 'slapd',
      :service  => 'slapd',
      :enable   => true,
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
         .that_comes_before('Class[openldap::server]') }
  end

end

