# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::client::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:ldap_conf_path) do
        case facts[:os]['family']
        when 'Debian'
          '/etc/ldap/ldap.conf'
        when 'FreeBSD'
          '/usr/local/etc/openldap/ldap.conf'
        when 'RedHat', 'Suse'
          '/etc/openldap/ldap.conf'
        end
      end

      context 'with no parameters set' do
        let :pre_condition do
          <<~PP
            class { 'openldap::client':
            }
          PP
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_file(ldap_conf_path).with(content: <<~LDAP_CONF) }
          # This file is managed by Puppet

        LDAP_CONF
      end

      context 'with all parameters set' do
        let :pre_condition do
          <<~PP
            class { 'openldap::client':
              base => 'dc=example,dc=com',
              bind_policy => 'soft',
              bind_timelimit => '10',
              binddn => 'cn=admin,dc=example,dc=com',
              bindpw => 'secret',
              ldap_version => '3',
              network_timeout => '1',
              scope => 'one',
              ssl => 'on',
              suffix => 'dc=example,dc=com',
              timelimit => '10',
              timeout => '10',
              uri => 'ldap://ldap.example.com',
              nss_base_group => 'ou=group,dc=example,dc=com',
              nss_base_hosts => 'ou=hosts,dc=example,dc=com',
              nss_base_passwd => 'ou=passwd,dc=example,dc=com',
              nss_base_shadow => 'ou=shadow,dc=example,dc=com',
              nss_initgroups_ignoreusers => 'ovahi,backup,games',
              pam_filter => 'type=FILTER',
              pam_login_attribute => 'uid',
              pam_member_attribute => 'memberUid',
              pam_password => 'md5',
              tls_cacert => '/etc/ssl/certs/ca-certificates.crt',
              tls_cacertdir => '/etc/ssl/certs/',
              tls_checkpeer => 'no',
              tls_reqcert => 'never',
              tls_moznss_compatibility => 'true',
              sasl_mech => 'gssapi',
              sasl_realm => 'TEST.REALM',
              sasl_authcid => 'dn:uid=test,cn=mech,cn=authzid',
              sasl_secprops => ['noplain','noactive'],
              sasl_nocanon => true,
              gssapi_sign => false,
              gssapi_encrypt => true,
              gssapi_allow_remote_principal => 'on',
              sudoers_base => 'ou=sudoers,dc=example,dc=com',
            }
          PP
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_file(ldap_conf_path).with(content: <<~LDAP_CONF) }
          # This file is managed by Puppet

          BASE dc=example,dc=com
          BIND_POLICY soft
          BIND_TIMELIMIT 10
          BINDDN cn=admin,dc=example,dc=com
          BINDPW secret
          LDAP_VERSION 3
          NETWORK_TIMEOUT 1
          SCOPE one
          SSL on
          SUFFIX dc=example,dc=com
          TIMELIMIT 10
          TIMEOUT 10
          URI ldap://ldap.example.com
          NSS_BASE_GROUP ou=group,dc=example,dc=com
          NSS_BASE_HOSTS ou=hosts,dc=example,dc=com
          NSS_BASE_PASSWD ou=passwd,dc=example,dc=com
          NSS_BASE_SHADOW ou=shadow,dc=example,dc=com
          NSS_INITGROUPS_IGNOREUSERS ovahi,backup,games
          PAM_FILTER type=FILTER
          PAM_LOGIN_ATTRIBUTE uid
          PAM_MEMBER_ATTRIBUTE memberUid
          PAM_PASSWORD md5
          TLS_CACERT /etc/ssl/certs/ca-certificates.crt
          TLS_CACERTDIR /etc/ssl/certs/
          TLS_CHECKPEER no
          TLS_REQCERT never
          TLS_MOZNSS_COMPATIBILITY true
          SASL_MECH gssapi
          SASL_REALM TEST.REALM
          SASL_AUTHCID dn:uid=test,cn=mech,cn=authzid
          SASL_SECPROPS noplain,noactive
          SASL_NOCANON true
          GSSAPI_SIGN false
          GSSAPI_ENCRYPT true
          GSSAPI_ALLOW_REMOTE_PRINCIPAL on
          SUDOERS_BASE ou=sudoers,dc=example,dc=com
        LDAP_CONF
      end

      context 'with multiple uri' do
        let :pre_condition do
          <<~PP
            class { 'openldap::client':
              uri => ['ldap://ldap1.example.com', 'ldap://ldap2.example.com'],
            }
          PP
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_file(ldap_conf_path).with(content: <<~LDAP_CONF) }
          # This file is managed by Puppet

          URI ldap://ldap1.example.com ldap://ldap2.example.com
        LDAP_CONF
      end
    end
  end
end
