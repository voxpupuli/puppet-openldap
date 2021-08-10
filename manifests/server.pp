# See README.md for details.
class openldap::server (
  String[1] $package,
  String[1] $confdir,
  String[1] $conffile,
  String[1] $service,
  String[1] $owner,
  String[1] $group,
  Boolean $escape_ldapi_ifs,
  Optional[Boolean] $enable_chown                   = undef,
  Optional[Boolean] $service_hasstatus              = undef,
  Boolean $enable                                   = true,
  Boolean $start                                    = true,
  Optional[Stdlib::Absolutepath] $ssl_key           = undef,
  Optional[Stdlib::Absolutepath] $ssl_cert          = undef,
  Optional[Stdlib::Absolutepath] $ssl_ca            = undef,
  Hash $databases                                   = {},
  Array[String[1]] $ldap_ifs                        = ['/'],
  Array[String[1]] $ldaps_ifs                       = [],
  Array[String[1]] $ldapi_ifs                       = ['/'],
  Optional[String] $slapd_params                    = undef,
  Optional[Stdlib::Port] $ldap_port                 = undef,
  Optional[Stdlib::IP::Address] $ldap_address       = undef,
  Optional[Stdlib::Port] $ldaps_port                = undef,
  Optional[Stdlib::IP::Address] $ldaps_address      = undef,
  Optional[Stdlib::Absolutepath] $ldapi_socket_path = undef,
  Optional[Boolean] $register_slp                   = undef,
  Optional[Stdlib::Absolutepath] $krb5_keytab_file  = undef,
  Optional[String] $ldap_config_backend             = undef,
  Optional[Boolean] $enable_memory_limit            = undef,
) {
  class { 'openldap::server::install': }
  -> class { 'openldap::server::config': }
  ~> class { 'openldap::server::service': }
  -> class { 'openldap::server::slapdconf': }
  -> Class['openldap::server']
}
