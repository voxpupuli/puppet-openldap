# See README.md for details.
class openldap::server::service {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  $ensure = $::openldap::server::start ? {
    true    => running,
    default => stopped,
  }

  if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == '8' {
    # Puppet4 fallback to init provider which does not support enableable
    $provider = 'debian'
  } else {
    $provider = undef
  }

  service { $::openldap::server::service:
    ensure    => $ensure,
    provider  => $provider,
    enable    => $::openldap::server::enable,
    hasstatus => $::openldap::server::service_hasstatus,
  }
}
