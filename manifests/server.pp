class openldap::server(
  $ssl      = false,
  $ssl_cert = undef,
  $ssl_key  = undef,
  $ssl_ca   = undef,

  $package  = $::osfamily ? {
    Debian => ['slapd', 'ldap-utils',],
  },
  $service  = $::osfamily ? {
    Debian => 'slapd',
  },
  $enable   = true,
  $start    = true,
) {
  class { 'openldap::server::install': } ->
  class { 'openldap::server::config': } ~>
  class { 'openldap::server::service': } ->
  Class['openldap::server']
}
