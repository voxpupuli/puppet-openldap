# See README.md for details.
define openldap::server::access (
  String[1]                            $what,
  Array[Openldap::Access_rule]         $access,
  Enum['present', 'absent']            $ensure   = 'present',
) {
  include openldap::server

  Class['openldap::server::service']
  -> Openldap::Server::Access[$title]
  -> Class['openldap::server']

  openldap_access { $title:
    ensure => $ensure,
    target => $openldap::server::conffile,
    what   => $what,
    access => $access,
  }
}
