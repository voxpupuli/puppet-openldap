# See README.md for details.
define openldap::server::globalconf(
  $value,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Globalconf[$title] ~> Class['openldap::server::service']
  }
  openldap_global_conf { $name:
    provider => $::openldap::server::provider,
    target   => $::openldap::server::conffile,
    value    => $value,
  }
}
