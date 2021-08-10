# See README.md for details.
define openldap::server::dbindex (
  $ensure    = undef,
  $suffix    = undef,
  $attribute = $name,
  $indices   = undef,
) {
  if ! defined(Class['openldap::server']) {
    fail 'class openldap::server has not been evaluated'
  }

  openldap_dbindex { $title:
    ensure    => $ensure,
    suffix    => $suffix,
    attribute => $attribute,
    indices   => $indices,
    require   => Class['openldap::server::service'],
    before    => Class['openldap::server'],
  }
}
