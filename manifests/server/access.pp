define openldap::server::access(
  $access   = $title,
  $position = undef,
  $suffix   = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Access[$title] ~> Class['openldap::service']
  }
  openldap_access { $title:
    access   => $access,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::file,
    position => $position,
    $suffix  => $suffix,
  }
}
