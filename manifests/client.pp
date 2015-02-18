# See README.md for details.
class openldap::client(
  $package    = $openldap::params::client_package,
  $file       = $openldap::params::client_conffile,

  # Options
  $base       = undef,
  $uri        = undef,

  # TLS Options
  $tls_cacert = undef,
) inherits ::openldap::params {
  anchor { 'openldap::client::begin': } ->
  class { '::openldap::client::install': } ->
  class { '::openldap::client::config': } ->
  anchor { 'openldap::client::end': }
}
