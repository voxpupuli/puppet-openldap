# See README.md for details.
define openldap::server::access (
  Optional[Enum['present', 'absent']]  $ensure   = undef,
  Optional[Variant[Integer,String[1]]] $position = undef, # FIXME We should probably choose Integer or String
  Optional[String[1]]                  $what     = undef,
  Optional[String[1]]                  $suffix   = undef,
  Optional[Array[String[1]]]           $access   = undef,
  Boolean                              $islast   = false,
) {
  if ! defined(Class['openldap::server']) {
    fail 'class openldap::server has not been evaluated'
  }

  Class['openldap::server::service']
  -> Openldap::Server::Access[$title]
  -> Class['openldap::server']

  openldap_access { $title:
    ensure   => $ensure,
    position => $position,
    target   => $openldap::server::conffile,
    what     => $what,
    suffix   => $suffix,
    access   => $access,
    islast   => $islast,
  }
}
