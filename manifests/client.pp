class openldap::client(
  $package    = $::osfamily ? {
    Debian => 'libldap-2.4-2',
  },

  $file       = $::osfamily ? {
    Debian => '/etc/ldap/ldap.conf',
  },

  # Options
  $base       = undef,
  $uri        = undef,

  # TLS Options
  $tls_cacert = undef,
) {
  class { 'openldap::client::install': } ->
  class { 'openldap::client::config': } ~>
  Class['openldap::client']
}
