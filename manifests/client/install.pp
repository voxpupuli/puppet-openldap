class openldap::client::install {
  package { $::openldap::client::package:
    ensure => present,
  }
}
