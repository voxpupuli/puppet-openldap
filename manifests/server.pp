# See README.md for details.
class openldap::server(
  $package   = $::osfamily ? {
    Debian => 'slapd',
    RedHat => 'openldap-servers',
  },
  $confdir   = $::osfamily ? {
    Debian => '/etc/ldap/slapd.d',
    RedHat => '/etc/openldap/slapd.d',
  },
  $conffile  = $::osfamily ? {
    Debian => '/etc/ldap/slapd.conf',
    RedHat => '/etc/openldap/slapd.conf',
  },
  $service   = $::osfamily ? {
    Debian => 'slapd',
    RedHat => $::operatingsystemmajrelease ? {
      5 => 'ldap',
      6 => 'slapd',
    },
  },
  $service_hasstatus = $::osfamily ? {
    Debian => $::operatingsystemmajrelease ? {
      5       => false,
      default => true,
    },
    RedHat => true,
  },
  $owner     = $::osfamily ? {
    Debian => 'openldap',
    RedHat => 'ldap',
  },
  $group     = $::osfamily ? {
    Debian => 'openldap',
    RedHat => 'ldap',
  },

  $ensure    = present,
  $enable    = true,
  $start     = true,

  $provider  = 'olc',

  $ssl_key   = undef,
  $ssl_cert  = undef,
  $ssl_ca    = undef,

  $suffix    = $::osfamily ? {
    Debian => sprintf('dc=%s', regsubst($::domain, '\.', ',dc=', 'G')),
    RedHat => 'dc=my-domain,dc=com',
  },

  $databases = {},

  $ldap_ifs  = ['/'],
  $ldaps_ifs = [],
  $ldapi_ifs = ['/'],
) {
  validate_re($ensure, ['^present', '^absent'])
  validate_hash($databases)

  class { 'openldap::server::install': } ->
  class { 'openldap::server::config': } ~>
  class { 'openldap::server::service': }

  class { 'openldap::server::slapdconf': }

  case $provider {
    augeas: {
      fail 'Augeas provider is temporarily disable as it does not work with latest version of augeasproviders'

      Class['openldap::server::install'] ->
      Class['openldap::server::slapdconf'] ~>
      Class['openldap::server::service'] ->
      Class['openldap::server']
    }
    olc: {
      Class['openldap::server::service'] ->
      Class['openldap::server::slapdconf'] ->
      Class['openldap::server']
    }
    default: {
      fail 'provider must be one of "olc" or "augeas"'
    }
  }
}
