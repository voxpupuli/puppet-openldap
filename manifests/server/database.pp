define openldap::server::database(
  $suffix  = $title,
  $backend = undef,
  $directory,
  $rootdn  = undef,
  $rootpw  = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Access[$title] ~> Class['openldap::service']
  }
  openldap_database { $title:
    suffix    => $suffix,
    provider  => $::openldap::server::provider,
    target    => $::openldap::server::file,
    backend   => $backend,
    direcotry => $directory,
    rootdn    => $rootdn,
    rootpw    => $rootpw,
  }
}
