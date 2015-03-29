# See README.md for details.
define openldap::server::schema(
  $ensure = undef,
  $path = false,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Schema[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Schema[$title] ->
    Class['openldap::server']
  }

  if $path {
      $pathWithDefault = $path
  } else {
      $pathWithDefault = $osfamily ? {
          'Debian' => "/etc/ldap/schema/$title.schema",
          'Redhat' => "/etc/openldap/schema/$title.schema",
          default => "/etc/ldap/schema/$title.schema",
      }
  }

  openldap_schema { $title:
    ensure   => $ensure,
    path     => $pathWithDefault,
    provider => $::openldap::server::provider,
  }
}
