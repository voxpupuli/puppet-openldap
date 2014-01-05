# See README.md for details.
class openldap::client(
  $package    = $::osfamily ? {
    Debian => 'libldap-2.4-2',
    RedHat => 'openldap',
  },

  $file       = $::osfamily ? {
    Debian => '/etc/ldap/ldap.conf',
    RedHat => '/etc/openldap/ldap.conf',
  },

  # Options
  $base       = undef,
  $uri        = undef,

  # TLS Options
  $tls_cacert = undef,
) {
  class { 'openldap::client::install': } ->
  class { 'openldap::client::config': } ->
  Class['openldap::client']
}
