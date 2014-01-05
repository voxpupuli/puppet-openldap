class openldap::server(
  $package  = $::osfamily ? {
    Debian => 'slapd',
    RedHat => 'openldap-servers',
  },
  $file     = $::osfamily ? {
    Debian => '/etc/ldap/slapd.conf',
    RedHat => '/etc/openldap/slapd.conf',
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

  $provider = undef,

  $ssl      = false,
  $ssl_cert = undef,
  $ssl_key  = undef,
  $ssl_ca   = undef,
) {
  if $provider != undef {
    validate_re(
      $provider,
      ['olc', 'augeas'],
      'provider must be one of "olc" or "augeas"')
  }

  class { 'openldap::server::install': } ->
  class { 'openldap::server::config': } ~>
  class { 'openldap::server::service': } ->
  Class['openldap::server']
}
