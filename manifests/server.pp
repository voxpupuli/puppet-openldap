# See README.md for details.
class openldap::server(
  $package   = $::osfamily ? {
    Debian => 'slapd',
    RedHat => 'openldap-servers',
  },
  $file      = $::osfamily ? {
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
  $owner     = $::osfamily ? {
    Debian => 'openldap',
    RedHat => 'ldap',
  },
  $group     = $::osfamily ? {
    Debian => 'openldap',
    RedHat => 'ldap',
  },

  $enable    = true,
  $start     = true,

  $provider  = 'olc',

  $ssl       = false,
  $ssl_key   = undef,
  $ssl_cert  = undef,
  $ssl_ca    = undef,

  $databases = hash(
    [
      sprintf('dc=%s', regsubst($::domain, '\.', ',dc=', 'G')),
      {
        directory => '/var/lib/ldap',
      },
    ]
  ),
  $default_database = undef,
) {
  class { 'openldap::server::install': }
  class { 'openldap::server::config': }
  class { 'openldap::server::service': }

  case $provider {
    augeas: {
      Class['openldap::server::install'] ->
      Class['openldap::server::config'] ~>
      Class['openldap::server::service'] ->
      Class['openldap::server']
    }
    olc: {
      Class['openldap::server::install'] ->
      Class['openldap::server::service'] ->
      Class['openldap::server::config'] ->
      Class['openldap::server']
    }
    default: {
      fail 'provider must be one of "olc" or "augeas"'
    }
  }
}
