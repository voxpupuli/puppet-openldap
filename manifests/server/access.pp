# See README.md for details.
define openldap::server::access(
  $ensure   = undef,
  $what     = undef,
  $by       = undef,
  $suffix   = undef,
  $access   = undef,
  $control  = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Openldap::Server::Access[$title] ~> Class['openldap::server::service']
  }
  openldap_access { $title:
    ensure   => $ensure,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::file,
    what     => $what,
    by       => $by,
    suffix   => $suffix,
    access   => $access,
    control  => $control,
  }
}
