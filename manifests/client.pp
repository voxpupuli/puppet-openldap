# See README.md for details.
class openldap::client(
  $package              = $openldap::params::client_package,
  $file                 = $openldap::params::client_conffile,

  # Options
  $base                 = undef,
  $bind_policy          = undef,
  $bind_timelimit       = undef,
  $binddn               = undef,
  $bindpw               = undef,
  $ldap_version         = undef,
  $scope                = undef,
  $ssl                  = undef,
  $suffix               = undef,
  $timelimit            = undef,
  $timeout              = undef,
  $uri                  = undef,

  # NSS Options
  $nss_base_group       = undef,
  $nss_base_hosts       = undef,
  $nss_base_passwd      = undef,
  $nss_base_shadow      = undef,

  # PAM Options
  $pam_filter           = undef,
  $pam_login_attribute  = undef,
  $pam_member_attribute = undef,
  $pam_password         = undef,

  # TLS Options
  $tls_cacert           = undef,
  $tls_cacertdir        = undef,
  $tls_checkpeer        = undef,
  $tls_reqcert          = undef,

  # SUDO Options
  $sudoers_base         = undef,
) inherits ::openldap::params {
  anchor { 'openldap::client::begin': } ->
  class { '::openldap::client::install': } ->
  class { '::openldap::client::config': } ->
  anchor { 'openldap::client::end': }
}
