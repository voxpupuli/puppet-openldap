# See README.md for details.
define openldap::server::database(
  $directory,
  $suffix  = $title,
  $backend = undef,
  $rootdn  = undef,
  $rootpw  = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Database[$title] ~> Class['openldap::server::service']
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
