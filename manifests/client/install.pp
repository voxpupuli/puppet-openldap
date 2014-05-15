# See README.md for details.
class openldap::client::install {

  if ! defined(Class['openldap::client']) {
    fail 'class ::openldap::client has not been evaluated'
  }

  if (defined(Class['openldap::server']) and $::openldap::server::ensure == present) or ($::openldap::client::ensure == present) {
    $ensure = present
  } else {
    $ensure = purged
  }
  package { $::openldap::client::package:
    ensure => $ensure,
  }
}
