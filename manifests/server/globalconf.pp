define openldap::server::globalconf(
  $value,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Access[$title] ~> Class['openldap::service']
  }
  openldap_global_conf { $name:
    provider => $::openldap::server::provider,
    target   => $::openldap::server::file,
    value    => $value,
  }
}
