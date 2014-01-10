require 'spec_helper'

describe 'openldap::server::globalconf' do

  let(:title) { 'foo' }

  context 'without value' do
    it { expect { should compile }.to raise_error(Puppet::Error, /Must pass value to Openldap::Server::Globalconf\[foo\]/) }
  end

  context 'with a value' do
    let(:params) {{ :value => 'bar' }}

    context 'on RedHat4' do
      let(:facts) {{
        :domain                    => 'example.com',
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 4,
        :openldap_server_version   => '2.2.13',
      }}

      context 'with no parameters' do
        let :pre_condition do
          "class { 'openldap::server': }"
        end

        it { should compile.with_all_deps }
        it { should contain_openldap__server__globalconf('foo')
             .with({:value => 'bar',})
             .that_notifies('Class[openldap::server::service]') }
      end
    end

    context 'on Debian7' do
      let(:facts) {{
        :domain                    => 'example.com',
        :osfamily                  => 'Debian',
        :openldap_server_version   => '2.4.31',
      }}

      context 'with no parameters' do
        let :pre_condition do
          "class { 'openldap::server': }"
        end

        it { should compile.with_all_deps }
        it { should contain_openldap__server__globalconf('foo').with({
          :value => 'bar',
        })}

      end
    end
  end

end
