class openldap::ldapvi(
  $package = 'ldapvi',
) {
  package { $package:
    ensure => present,
  }
}
