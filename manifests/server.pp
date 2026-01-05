# See README.md for details.
# @param krb5_keytab_file
#   if set, manage the env variable KRB5_KTNAME on Debian based operating systems. This is required when
#   configuring sasl with backend GSSAPI
# @param krb5_client_keytab_file
#   if set, manage the env variable KRB5_CLIENT_KTNAME on Debian based operating systems. This is required when
#   configuring sasl with backend GSSAPI
# @param pldap_ifs
#   Allows to configure the HAProxy PROXY protol handling of openldap.
#   This allows to get IPs of clients through a load-balancer for logging or filtering.
#   Must not use the same ports as the native listeners.
# @param pldaps_ifs
#   Allows to configure the HAProxy PROXY protol handling of openldap.
#   This allows to get IPs of clients through a load-balancer for logging or filtering.
#   Must not use the same ports as the native listeners.
class openldap::server (
  String[1] $package,
  String[1] $confdir,
  String[1] $conffile,
  String[1] $service,
  String[1] $owner,
  String[1] $group,
  Boolean $escape_ldapi_ifs,
  Array[String[1]] $ldapi_ifs,
  Stdlib::Absolutepath $default_directory,
  Boolean $manage_epel                              = true,
  String[1] $package_version                        = installed,
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
  Array[String[1]] $pldaps_ifs                      = [],
  Array[String[1]] $pldap_ifs                       = [],
  Optional[String] $slapd_params                    = undef,
  Optional[Stdlib::Port] $ldap_port                 = undef,
  Optional[Stdlib::IP::Address] $ldap_address       = undef,
  Optional[Stdlib::Port] $ldaps_port                = undef,
  Optional[Stdlib::IP::Address] $ldaps_address      = undef,
  Optional[Stdlib::Absolutepath] $ldapi_socket_path = undef,
  Optional[Boolean] $register_slp                   = undef,
  Optional[Stdlib::Absolutepath] $krb5_keytab_file  = undef,
  Optional[Stdlib::Absolutepath] $krb5_client_keytab_file  = undef,
  Optional[String] $ldap_config_backend             = undef,
  Optional[Boolean] $enable_memory_limit            = undef,
) {
  include openldap::server::install
  include openldap::server::config
  include openldap::server::service
  include openldap::server::slapdconf

  Class['openldap::server::install']
  -> Class['openldap::server::config']
  ~> Class['openldap::server::service']
  -> Class['openldap::server::slapdconf']
  -> Class['openldap::server']
}
