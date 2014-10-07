# See README.md for details.
define openldap::server::database(
  $ensure    = present,
  $directory = '/var/lib/ldap',
  $suffix    = $title,
  $backend   = undef,
  $rootdn    = undef,
  $rootpw    = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Database[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Database[$title] ->
    Class['openldap::server']
  }

  if $ensure == present {
    validate_absolute_path($directory)
    file { $directory:
      ensure => directory,
      owner  => $::openldap::server::owner,
      group  => $::openldap::server::group,
      before => Openldap_database[$title],
    }
  }

  openldap_database { $title:
    ensure    => $ensure,
    suffix    => $suffix,
    provider  => $::openldap::server::provider,
    target    => $::openldap::server::conffile,
    backend   => $backend,
    directory => $directory,
    rootdn    => $rootdn,
    rootpw    => $rootpw,
  }

}
