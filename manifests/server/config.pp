# See README.md for details.
class openldap::server::config {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  case $::osfamily {
    Debian: {
      $slapd_services = $::openldap::server::ssl ? {
        true  => 'ldap:/// ldaps:/// ldapi:///',
        false => 'ldap:/// ldapi:///',
      }

      shellvar { 'slapd':
        ensure   => present,
        target   => '/etc/default/slapd',
        variable => 'SLAPD_SERVICES',
        value    => $slapd_services,
      }
    }
    RedHat: {
      shellvar { 'SLAPD_LDAP':
        ensure   => present,
        target   => '/etc/sysconfig/ldap',
        variable => 'SLAPD_LDAP',
        value    => 'yes',
      }
      $slapd_ldaps_ensure = $::openldap::server::ssl ? {
        true  => present,
        false => absent,
      }
      $ldaps = $::openldap::server::ssl ? {
        true  => 'yes',
        false => 'no',
      }
      shellvar { 'SLAPD_LDAPS':
        ensure   => $slapd_ldaps_ensure,
        target   => '/etc/sysconfig/ldap',
        variable => 'SLAPD_LDAPS',
        value    => $::openldap::server::ssl,
      }
      shellvar { 'SLAPD_LDAPI':
        ensure   => present,
        target   => '/etc/sysconfig/ldap',
        variable => 'SLAPD_LDAPI',
        value    => 'yes',
      }
    }
    default: {
      fail "Operating System Family ${::osfamily} not yet supported"
    }
  }

}
