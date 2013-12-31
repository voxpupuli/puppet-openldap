class openldap::server::install {
  package { $::openldap::server::package:
    ensure => present,
  }
}
