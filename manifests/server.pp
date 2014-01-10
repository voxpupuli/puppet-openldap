# See README.md for details.
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
      /(4|5)/ => 'ldap',
      /(6|7)/ => 'slapd',
    },
  },

  $enable   = true,
  $start    = true,

  $provider = versioncmp($::openldap_server_version, '2.3.0') ? {
    '-1'    => 'augeas',
    default => 'olc',
  },

  $ssl      = false,
  $ssl_cert = undef,
  $ssl_key  = undef,
  $ssl_ca   = undef,
) {
  validate_re(
    $provider,
    ['olc', 'augeas'],
    'provider must be one of "olc" or "augeas"')

  class { 'openldap::server::install': } ->
  class { 'openldap::server::config': } ~>
  class { 'openldap::server::service': } ->
  Class['openldap::server']
}
