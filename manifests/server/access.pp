# See README.md for details.
define openldap::server::access(
  $ensure   = undef,
  $position = undef,
  $what     = undef,
  $suffix   = undef,
  $by       = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Access[$title] ~> Class['openldap::server::service']
  }
  openldap_access { $title:
    ensure   => $ensure,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::file,
    position => $position,
    what     => $what,
    suffix   => $suffix,
    by       => $by,
  }
}
