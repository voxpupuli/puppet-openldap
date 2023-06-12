# See README.md for details.
class openldap::client (
  String[1]                                     $package,
  Stdlib::Absolutepath                          $file,

  # Options
  String[1]                                     $package_version               = installed,
  Optional[String[1]]                           $base                          = undef,
  Optional[String[1]]                           $bind_policy                   = undef,
  Optional[String[1]]                           $bind_timelimit                = undef,
  Optional[String[1]]                           $binddn                        = undef,
  Optional[String[1]]                           $bindpw                        = undef,
  Optional[String[1]]                           $ldap_version                  = undef,
  Optional[String[1]]                           $network_timeout               = undef,
  Optional[String[1]]                           $scope                         = undef,
  Optional[String[1]]                           $ssl                           = undef,
  Optional[String[1]]                           $suffix                        = undef,
  Optional[String[1]]                           $timelimit                     = undef,
  Optional[String[1]]                           $timeout                       = undef,
  Optional[Variant[String[1],Array[String[1]]]] $uri                           = undef,

  # NSS Options
  Optional[String[1]]                           $nss_base_group                = undef,
  Optional[String[1]]                           $nss_base_hosts                = undef,
  Optional[String[1]]                           $nss_base_passwd               = undef,
  Optional[String[1]]                           $nss_base_shadow               = undef,
  Optional[String[1]]                           $nss_initgroups_ignoreusers    = undef,

  # PAM Options
  Optional[String[1]]                           $pam_filter                    = undef,
  Optional[String[1]]                           $pam_login_attribute           = undef,
  Optional[String[1]]                           $pam_member_attribute          = undef,
  Optional[String[1]]                           $pam_password                  = undef,

  # TLS Options
  Optional[Stdlib::Absolutepath]                $tls_cacert                    = undef,
  Optional[Stdlib::Absolutepath]                $tls_cacertdir                 = undef,
  Optional[String[1]]                           $tls_checkpeer                 = undef,
  Optional[String[1]]                           $tls_reqcert                   = undef,
  Optional[Openldap::Tls_moznss_compatibility]  $tls_moznss_compatibility      = undef,

  # SASL Options
  Optional[String[1]]                           $sasl_mech                     = undef,
  Optional[String[1]]                           $sasl_realm                    = undef,
  Optional[String[1]]                           $sasl_authcid                  = undef,
  Optional[Array[String[1]]]                    $sasl_secprops                 = undef,
  Optional[Boolean]                             $sasl_nocanon                  = undef,

  # GSSAPI Options
  Optional[Boolean]                             $gssapi_sign                   = undef,
  Optional[Boolean]                             $gssapi_encrypt                = undef,
  Optional[String[1]]                           $gssapi_allow_remote_principal = undef,

  # SUDO Options
  Optional[String[1]]                           $sudoers_base                  = undef,
) {
  contain openldap::client::install
  contain openldap::client::config
  Class['openldap::client::install'] -> Class['openldap::client::config']
}
