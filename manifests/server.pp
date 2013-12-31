class openldap::server(
  $package  = $::osfamily ? {
    Debian => 'slapd',
  },
  $service  = $::osfamily ? {
    Debian => 'slapd',
  },

  $enable   = true,
  $start    = true,

  $ssl      = false,
  $ssl_cert = undef,
  $ssl_key  = undef,
  $ssl_ca   = undef,
) {
  class { 'openldap::server::install': } ->
  class { 'openldap::server::config': } ~>
  class { 'openldap::server::service': } ->
  Class['openldap::server']
}
