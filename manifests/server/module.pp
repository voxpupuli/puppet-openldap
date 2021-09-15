# See README.md for details.
define openldap::server::module (
  Optional[Enum['present', 'absent']] $ensure = undef,
) {
  include openldap::server

  Class['openldap::server::service']
  -> Openldap::Server::Module[$title]
  -> Class['openldap::server']

  openldap_module { $title:
    ensure   => $ensure,
  }
}
