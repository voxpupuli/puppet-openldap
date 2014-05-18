# See README.md for details.
class openldap::client::utils(
  $package = $::osfamily ? {
    Debian => 'ldap-utils',
    RedHat => 'openldap-clients',
  },
) {
  package { $package:
    ensure => present,
  }
}
