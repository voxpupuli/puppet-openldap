# See README.md for details.
# @param manage_policy_rc_d
#   If set, manage /usr/sbin/policy-rc.d on Debian based operating systems to not automatically start the LDAP server
#   when installing slapd.  This is required when preseeding the package with the no_configuration flag as we have to.
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
  Optional[Boolean] $manage_policy_rc_d             = undef,
) {
  include openldap::server::install
  include openldap::server::config
  include openldap::server::service
  include openldap::server::slapdconf

  unless $manage_policy_rc_d =~ Undef {
    deprecation('manage_policy_rc_d', 'The manage_policy_rc_d parameter is deprecated and unused. It will be removed in a future version.')
  }

  Class['openldap::server::install']
  -> Class['openldap::server::config']
  ~> Class['openldap::server::service']
  -> Class['openldap::server::slapdconf']
  -> Class['openldap::server']
}
