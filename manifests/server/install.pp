# See README.md for details.
class openldap::server::install {
  package { $::openldap::server::package:
    ensure => present,
  }
}
