# See README.md for details.
define openldap::server::overlay (
  Enum['present', 'absent']      $ensure  = present,
  String[1]                      $overlay = regsubst($title, '^(\S+)\s+on\s+(\S+)$', '\1'),
  String[1]                      $suffix  = regsubst($title, '^(\S+)\s+on\s+(\S+)$', '\2'),
  Optional[Openldap::Attributes] $options = undef,
) {
  include openldap::server

  Class['openldap::server::service']
  -> Openldap::Server::Overlay[$title]
  -> Class['openldap::server']

  openldap_overlay { "${overlay} on ${suffix}":
    ensure  => $ensure,
    overlay => $overlay,
    suffix  => $suffix,
    options => $options,
  }
}
