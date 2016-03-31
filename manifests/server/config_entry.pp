define openldap::server::config_entry (
  $value,
  $key = $title,
  $replace = true,
  $ensure  = 'present',
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  # Use a unique hash instead of the actual value to identify it
  $hashed_value = openldap_md5($value, 'openldap_config_entry')
  $hashed_name = "${key}-${hashed_value}"

  openldap_config_entry { $hashed_name:
    ensure   => $ensure,
    provider => $::openldap::server::provider,
    target   => $::openldap::server::conffile,
    key      => $key,
    value    => $value,
    replace  => $replace,
  }
}
