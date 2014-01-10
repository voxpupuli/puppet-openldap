require 'spec_helper'

describe 'openldap::server::database' do

  let(:title) { 'foo' }

  context 'without directory' do
    it { expect { should compile }
      .to raise_error(Puppet::Error, /Must pass directory to Openldap::Server::Database\[foo\]/)
    }
  end

  context 'with an invalid directory' do
    let(:params) {{ :directory => 'bar' }}

    it { expect { should compile }
      .to raise_error(Puppet::Error, /\"bar\" is not an absolute path/)
    }
  end

  context 'without declaring Class[openldap::server]' do
    let(:params) {{ :directory => '/foo/bar' }}

    it { expect { should compile }
      .to raise_error(Puppet::Error, /Could not find resource .* for relationship on .*/)
    }
  end

  context 'with a valid directory' do
    let(:params) {{ :directory => '/foo/bar' }}

    context 'on RedHat4' do
      let(:facts) {{
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 4,
        :openldap_server_version   => '2.2.13',
      }}

      context 'with no parameters' do
        let :pre_condition do
          "class { 'openldap::server': }"
        end

        it { should compile.with_all_deps }
        it { should contain_openldap__server__database('foo')
             .with({:directory => '/foo/bar',})
             .that_notifies('Class[openldap::server::service]') }
      end
    end

    context 'on Debian7' do
      let(:facts) {{
        :osfamily                  => 'Debian',
        :openldap_server_version   => '2.4.31',
      }}

      context 'with no parameters' do
        let :pre_condition do
          "class { 'openldap::server': }"
        end

        it { should compile.with_all_deps }
        it { should contain_openldap__server__database('foo')
          .with({
            :directory => '/foo/bar',
          })
        }

      end
    end
  end

end
