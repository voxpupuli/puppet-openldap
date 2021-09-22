# See README.md for details.
define openldap::server::globalconf (
  Variant[String[1],Array[String[1],1],Openldap::Attributes] $value,
  Enum['present', 'absent']                                  $ensure = 'present',
) {
  include openldap::server

  Class['openldap::server::service']
  -> Openldap::Server::Globalconf[$title]
  -> Class['openldap::server']

  openldap_global_conf { $name:
    ensure => $ensure,
    target => $openldap::server::conffile,
    value  => $value,
  }
}
