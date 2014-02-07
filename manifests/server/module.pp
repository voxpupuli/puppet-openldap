# See README.md for details.
define openldap::server::module(
  $ensure = undef,
) {
  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install'] ->
    Openldap::Server::Module[$title] ~>
    Class['openldap::server::service']
  } else {
    Class['openldap::server::service'] ->
    Openldap::Server::Module[$title] ->
    Class['openldap::server']
  }

  openldap_module { $title:
    ensure   => $ensure,
    provider => $::openldap::server::provider,
  }
}
