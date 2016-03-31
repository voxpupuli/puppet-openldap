# See README.md for details.
define openldap::server::config_hash(
  $value,
  $ensure = 'present',
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Globalconf[$title] ~> Class['openldap::server::service']
  }
  openldap_config_hash { $name:
    ensure   => $ensure,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::conffile,
    value    => $value,
  }
}
