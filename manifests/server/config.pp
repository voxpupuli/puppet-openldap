# See README.md for details.
class openldap::server::config {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  $slapd_ldap_ifs = empty($::openldap::server::ldap_ifs) ? {
    false => join(prefix($::openldap::server::ldap_ifs, 'ldap://'), ' '),
    true  => '',
  }
  $slapd_ldapi_ifs = empty($::openldap::server::ldapi_ifs) ? {
    false => join(prefix($::openldap::server::ldapi_ifs, 'ldapi://'), ' '),
    true  => '',
  }
  $slapd_ldaps_ifs = empty($::openldap::server::ldaps_ifs) ? {
    false  => join(prefix($::openldap::server::ldaps_ifs, 'ldaps://'), ' '),
    true => '',
  }
  $slapd_ldap_urls = "${slapd_ldap_ifs} ${slapd_ldapi_ifs} ${slapd_ldaps_ifs}"

  case $::osfamily {
    'Debian': {
      shellvar { 'slapd':
        ensure   => present,
        target   => '/etc/default/slapd',
        variable => 'SLAPD_SERVICES',
        value    => $slapd_ldap_urls,
      }
    }
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '6') <= 0 {
        $ldap = empty($::openldap::server::ldap_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAP':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAP',
          value    => $ldap,
        }
        $ldaps = empty($::openldap::server::ldaps_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPS':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPS',
          value    => $ldaps,
        }
        $ldapi = empty($::openldap::server::ldapi_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPI':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPI',
          value    => $ldapi,
        }
      } else {
        shellvar { 'slapd':
          ensure   => present,
          target   => '/etc/sysconfig/slapd',
          variable => 'SLAPD_URLS',
          value    => $slapd_ldap_urls,
        }
      }
    }
    default: {
      fail "Operating System Family ${::osfamily} not yet supported"
    }
  }
}
