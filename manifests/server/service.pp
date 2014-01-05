# See README.md for details.
class openldap::server::service {
  $ensure = $::openldap::server::start ? {
    true    => running,
    default => stopped,
  }

  service { $::openldap::server::service:
    ensure => $ensure,
    enable => $::openldap::server::enable,
  }
}
