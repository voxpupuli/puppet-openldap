# See README.md for details.
define openldap::server::access(
  $ensure   = undef,
  $position = undef,
  $what     = undef,
  $by       = undef,
  $suffix   = undef,
  $access   = undef,
  $control  = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Access[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Access[$title] ->
    Class['openldap::server']
  }

  openldap_access { $title:
    ensure   => $ensure,
    position => $position,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::conffile,
    what     => $what,
    by       => $by,
    suffix   => $suffix,
    access   => $access,
    control  => $control,
  }
}
