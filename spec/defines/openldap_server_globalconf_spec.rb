require 'spec_helper'

describe 'openldap::server::globalconf' do

  let(:title) { 'foo' }

  let(:facts) {{
    :domain                    => 'example.com',
    :osfamily                  => 'Debian',
    :operatingsystemmajrelease => '7',
  }}

  context 'without value' do
    it { expect { should compile }.to raise_error(Puppet::Error, /Must pass value to Openldap::Server::Globalconf\[foo\]/) }
  end

  context 'with a value' do
    let(:params) {{ :value => 'bar' }}

    context 'with olc provider' do
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
