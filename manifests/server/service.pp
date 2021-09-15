# See README.md for details.
class openldap::server::service {
  include openldap::server

  $ensure = $openldap::server::start ? {
    true    => running,
    default => stopped,
  }

  service { $openldap::server::service:
    ensure    => $ensure,
    enable    => $openldap::server::enable,
    hasstatus => $openldap::server::service_hasstatus,
  }
}
