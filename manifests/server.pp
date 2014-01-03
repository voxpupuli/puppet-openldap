class openldap::server(
  $package  = $::osfamily ? {
    Debian => 'slapd',
    RedHat => 'openldap-servers',
  },
  $service  = $::osfamily ? {
    Debian => 'slapd',
    RedHat => $::operatingsystemmajrelease ? {
      5 => 'ldap',
      6 => 'slapd',
    }
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
