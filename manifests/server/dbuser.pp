# See README.md for details.
define openldap::server::dbuser(
  $ensure = 'present',
  $suffix = undef,
  $user   = $title,
  $passwd = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install']
    -> Openldap::Server::Database[$suffix]
    -> Openldap::Server::Dbuser[$title]
    ~> Class['openldap::server::service']
  } else {
    Class['openldap::server::service']
    -> Openldap::Server::Database[$suffix]
    -> Openldap::Server::Dbuser[$title]
    -> Class['openldap::server']
  }

  openldap_dbuser { $title:
    ensure   => $ensure,
    suffix   => $suffix,
    user     => $user,
    passwd   => $passwd,
  }
}
