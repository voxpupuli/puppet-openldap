# See README.md for details.
class openldap::ldapvi(
  $package = 'ldapvi',
) {
  package { $package:
    ensure => present,
  }
}
