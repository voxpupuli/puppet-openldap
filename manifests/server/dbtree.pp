# See README.md for details.
define openldap::server::dbtree(
  $ensure = 'present',
  $suffix = undef,
  $tree   = $title,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    Class['openldap::server::install']
    -> Openldap::Server::Database[$suffix]
    -> Openldap::Server::Dbtree[$title]
    ~> Class['openldap::server::service']
  } else {
    Class['openldap::server::service']
    -> Openldap::Server::Database[$suffix]
    -> Openldap::Server::Dbtree[$title]
    -> Class['openldap::server']
  }

  openldap_dbtree { $title:
    ensure => $ensure,
    suffix => $suffix,
    tree   => $tree,
  }
}
