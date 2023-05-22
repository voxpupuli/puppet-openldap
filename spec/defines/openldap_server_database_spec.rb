# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::database' do
  let(:title) { 'dc=foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with a valid directory' do
        let(:params) { { directory: '/foo/bar' } }

        context 'with olc provider' do
          context 'with no parameters' do
            it { is_expected.to compile.with_all_deps }

            it {
              is_expected.to contain_openldap__server__database('dc=foo').with(directory: '/foo/bar')
            }
          end

          context 'with all parameters set' do
            let(:params) do
              {
                ensure: 'present',
                relay: 'relay',
                backend: 'ldap',
                rootdn: 'cn=admin,dc=example,dc=com',
                rootpw: 'secret',
                initdb: true,
                readonly: false,
                sizelimit: '10000',
                dbmaxsize: '10000',
                timelimit: '10000',
                updateref: 'default_updateref',
                limits: [
                  'dn.exact="cn=anyuser,dc=example,dc=org" size=100000',
                  'dn.exact="cn=personnel,dc=example,dc=org" size=unlimited',
                  'dn.exact="cn=dirsync,dc=example,dc=org" size=100000'
                ],
                dboptions: {
                  config: [
                    'set_cachesize 0 10485760 0',
                    'set_lg_bsize 2097512',
                    'set_lg_dir /var/tmp/bdb-log',
                    'set_flags DB_LOG_AUTOREMOVE',
                  ],
                },
                synctype: 'inclusive',
                mirrormode: true,
                multiprovider: true,
                syncusesubentry: 'wxw',
                syncrepl: [
                  'rid=1 provider=ldap://localhost searchbase="dc=foo,dc=example,dc=com"',
                  'rid=2 provider=ldap://localhost searchbase="dc=foo,dc=example,dc=com"',
                ],
                security: {
                  tls: 1,
                },
              }
            end

            it { is_expected.to compile.with_all_deps }
          end
        end
      end
    end
  end
end
