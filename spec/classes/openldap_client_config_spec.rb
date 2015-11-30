require 'spec_helper'

describe 'openldap::client::config' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        let :pre_condition do
          "class {'openldap::client':}"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
      end

      context 'with base set' do
        let :pre_condition do
          "class {'openldap::client': base => 'dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set BASE dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set BASE dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with bind_policy set' do
        let :pre_condition do
          "class {'openldap::client': bind_policy => 'soft', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set BIND_POLICY soft' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set BIND_POLICY soft' ],
          })
          }
        end
      end

      context 'with bind_timelimit set' do
        let :pre_condition do
          "class {'openldap::client': bind_timelimit => '10', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set BIND_TIMELIMIT 10' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set BIND_TIMELIMIT 10' ],
          })
          }
        end
      end

      context 'with binddn set' do
        let :pre_condition do
          "class {'openldap::client': binddn => 'cn=admin,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set BINDDN cn=admin,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set BINDDN cn=admin,dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with bindpw set' do
        let :pre_condition do
          "class {'openldap::client': bindpw => 'secret', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set BINDPW secret' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set BINDPW secret' ],
          })
          }
        end
      end

      context 'with ldap_version set' do
        let :pre_condition do
          "class {'openldap::client': ldap_version => '3', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set LDAP_VERSION 3' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set LDAP_VERSION 3' ],
          })
          }
        end
      end

      context 'with scope set' do
        let :pre_condition do
          "class {'openldap::client': scope => 'one', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set SCOPE one' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set SCOPE one' ],
          })
          }
        end
      end

      context 'with ssl set' do
        let :pre_condition do
          "class {'openldap::client': ssl => 'on', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set SSL on' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set SSL on' ],
          })
          }
        end
      end

      context 'with suffix set' do
        let :pre_condition do
          "class {'openldap::client': suffix => 'dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set SUFFIX dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set SUFFIX dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with timelimit set' do
        let :pre_condition do
          "class {'openldap::client': timelimit => '10', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TIMELIMIT 10' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TIMELIMIT 10' ],
          })
          }
        end
      end

      context 'with timeout set' do
        let :pre_condition do
          "class {'openldap::client': timeout => '10', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TIMEOUT 10' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TIMEOUT 10' ],
          })
          }
        end
      end

      context 'with uri set' do
        let :pre_condition do
          "class {'openldap::client': uri => 'ldap://ldap.example.com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ "set URI 'ldap://ldap.example.com'" ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ "set URI 'ldap://ldap.example.com'" ],
          })
          }
        end
      end

      context 'with multiple uri set' do
        let :pre_condition do
          "class {'openldap::client': uri => ['ldap://ldap1.example.com', 'ldap://ldap2.example.com'] }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ "set URI 'ldap://ldap1.example.com ldap://ldap2.example.com'" ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ "set URI 'ldap://ldap1.example.com ldap://ldap2.example.com'" ],
          })
          }
        end
      end

      context 'with nss_base_group set' do
        let :pre_condition do
          "class {'openldap::client': nss_base_group => 'ou=group,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set NSS_BASE_GROUP ou=group,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set NSS_BASE_GROUP ou=group,dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with nss_base_hosts set' do
        let :pre_condition do
          "class {'openldap::client': nss_base_hosts => 'ou=hosts,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set NSS_BASE_HOSTS ou=hosts,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set NSS_BASE_HOSTS ou=hosts,dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with nss_base_passwd set' do
        let :pre_condition do
          "class {'openldap::client': nss_base_passwd => 'ou=passwd,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set NSS_BASE_PASSWD ou=passwd,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set NSS_BASE_PASSWD ou=passwd,dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with nss_base_shadow set' do
        let :pre_condition do
          "class {'openldap::client': nss_base_shadow => 'ou=shadow,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set NSS_BASE_SHADOW ou=shadow,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set NSS_BASE_SHADOW ou=shadow,dc=example,dc=com' ],
          })
          }
        end
      end

      context 'with pam_filter set' do
        let :pre_condition do
          "class {'openldap::client': pam_filter => 'type=FILTER', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set PAM_FILTER type=FILTER' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set PAM_FILTER type=FILTER' ],
          })
          }
        end
      end

      context 'with pam_login_attribute set' do
        let :pre_condition do
          "class {'openldap::client': pam_login_attribute => 'uid', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set PAM_LOGIN_ATTRIBUTE uid' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set PAM_LOGIN_ATTRIBUTE uid' ],
          })
          }
        end
      end

      context 'with pam_member_attribute set' do
        let :pre_condition do
          "class {'openldap::client': pam_member_attribute => 'memberUid', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set PAM_MEMBER_ATTRIBUTE memberUid' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set PAM_MEMBER_ATTRIBUTE memberUid' ],
          })
          }
        end
      end

      context 'with pam_password set' do
        let :pre_condition do
          "class {'openldap::client': pam_password => 'md5', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set PAM_PASSWORD md5' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set PAM_PASSWORD md5' ],
          })
          }
        end
      end

      context 'with an invalid tls_cacert set' do
        let :pre_condition do
          "class {'openldap::client': tls_cacert => 'foo', }"
        end

        it { expect { is_expected.to compile }.to raise_error(/\"foo\" is not an absolute path/) }
      end

      context 'with a valid tls_cacert set' do
        let :pre_condition do
          "class {'openldap::client': tls_cacert => '/etc/ssl/certs/ca-certificates.crt', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TLS_CACERT /etc/ssl/certs/ca-certificates.crt' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TLS_CACERT /etc/ssl/certs/ca-certificates.crt' ],
          })
          }
        end
      end

      context 'with an invalid tls_cacertdir set' do
        let :pre_condition do
          "class {'openldap::client': tls_cacertdir => 'foo', }"
        end

        it { expect { is_expected.to compile }.to raise_error(/\"foo\" is not an absolute path/) }
      end

      context 'with a valid tls_cacertdir set' do
        let :pre_condition do
          "class {'openldap::client': tls_cacertdir => '/etc/ssl/certs/', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TLS_CACERTDIR /etc/ssl/certs/' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TLS_CACERTDIR /etc/ssl/certs/' ],
          })
          }
        end
      end

      context 'with tls_checkpeer set' do
        let :pre_condition do
          "class {'openldap::client': tls_checkpeer => 'no', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TLS_CHECKPEER no' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TLS_CHECKPEER no' ],
          })
          }
        end
      end

      context 'with tls_reqcert set' do
        let :pre_condition do
          "class {'openldap::client': tls_reqcert => 'never', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set TLS_REQCERT never' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set TLS_REQCERT never' ],
          })
          }
        end
      end

      context 'with sudoers_base set' do
        let :pre_condition do
          "class {'openldap::client': sudoers_base => 'ou=sudoers,dc=example,dc=com', }"
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openldap::client::config') }
        it { is_expected.to contain_augeas('ldap.conf') }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/ldap/ldap.conf',
            :changes => [ 'set SUDOERS_BASE ou=sudoers,dc=example,dc=com' ],
          })
          }
        when 'RedHat'
          it { is_expected.to contain_augeas('ldap.conf').with({
            :incl    => '/etc/openldap/ldap.conf',
            :changes => [ 'set SUDOERS_BASE ou=sudoers,dc=example,dc=com' ],
          })
          }
        end
      end
    end
  end
end
