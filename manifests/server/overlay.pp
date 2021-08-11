# See README.md for details.
define openldap::server::overlay (
  Enum['present', 'absent']                                     $ensure  = present,
  String[1]                                                     $overlay = regsubst($title, '^(\S+)\s+on\s+(\S+)$', '\1'),
  String[1]                                                     $suffix  = regsubst($title, '^(\S+)\s+on\s+(\S+)$', '\2'),
  Optional[Variant[Array[String[1]],Hash[String[1],String[1]]]] $options = undef,
) {
  if ! defined(Class['openldap::server']) {
    fail 'class openldap::server has not been evaluated'
  }

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
