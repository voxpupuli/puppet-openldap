# See README.md for details.
define openldap::server::dbindex (
  Optional[Enum['present', 'absent']] $ensure    = undef,
  Optional[String[1]]                 $suffix    = undef,
  String[1]                           $attribute = $name,
  Optional[String[1]]                 $indices   = undef,
) {
  include openldap::server

  openldap_dbindex { $title:
    ensure    => $ensure,
    suffix    => $suffix,
    attribute => $attribute,
    indices   => $indices,
    require   => Class['openldap::server::service'],
    before    => Class['openldap::server'],
  }
}
