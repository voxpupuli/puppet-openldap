# See README.md for details.
class openldap::client::ldapvi (
  String[1] $package = 'ldapvi',
) {
  package { $package:
    ensure => present,
  }
}
