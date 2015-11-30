# See README.md for details.
class openldap::client::config {
  $base = $::openldap::client::base ? {
    undef   => undef,
    default => "set BASE ${::openldap::client::base}",
  }
  $bind_policy = $::openldap::client::bind_policy ? {
    undef   => undef,
    default => "set BIND_POLICY ${::openldap::client::bind_policy}",
  }
  $bind_timelimit = $::openldap::client::bind_timelimit ? {
    undef   => undef,
    default => "set BIND_TIMELIMIT ${::openldap::client::bind_timelimit}",
  }
  $binddn = $::openldap::client::binddn ? {
    undef   => undef,
    default => "set BINDDN ${::openldap::client::binddn}",
  }
  $bindpw = $::openldap::client::bindpw ? {
    undef   => undef,
    default => "set BINDPW ${::openldap::client::bindpw}",
  }
  $ldap_version = $::openldap::client::ldap_version ? {
    undef   => undef,
    default => "set LDAP_VERSION ${::openldap::client::ldap_version}",
  }
  $scope = $::openldap::client::scope ? {
    undef   => undef,
    default => "set SCOPE ${::openldap::client::scope}",
  }
  $ssl = $::openldap::client::ssl ? {
    undef   => undef,
    default => "set SSL ${::openldap::client::ssl}",
  }
  $suffix = $::openldap::client::suffix ? {
    undef   => undef,
    default => "set SUFFIX ${::openldap::client::suffix}",
  }
  $timelimit = $::openldap::client::timelimit ? {
    undef   => undef,
    default => "set TIMELIMIT ${::openldap::client::timelimit}",
  }
  $timeout = $::openldap::client::timeout ? {
    undef   => undef,
    default => "set TIMEOUT ${::openldap::client::timeout}",
  }
  $_uri = $::openldap::client::uri ? {
    undef   => undef,
    default => join(flatten([$::openldap::client::uri]), ' '),
  }
  $uri = $_uri ? {
    undef   => undef,
    default => "set URI '${_uri}'",
  }
  $nss_base_group = $::openldap::client::nss_base_group ? {
    undef   => undef,
    default => "set NSS_BASE_GROUP ${::openldap::client::nss_base_group}",
  }
  $nss_base_hosts = $::openldap::client::nss_base_hosts ? {
    undef   => undef,
    default => "set NSS_BASE_HOSTS ${::openldap::client::nss_base_hosts}",
  }
  $nss_base_passwd = $::openldap::client::nss_base_passwd ? {
    undef   => undef,
    default => "set NSS_BASE_PASSWD ${::openldap::client::nss_base_passwd}",
  }
  $nss_base_shadow = $::openldap::client::nss_base_shadow ? {
    undef   => undef,
    default => "set NSS_BASE_SHADOW ${::openldap::client::nss_base_shadow}",
  }
  $pam_filter = $::openldap::client::pam_filter ? {
    undef   => undef,
    default => "set PAM_FILTER ${::openldap::client::pam_filter}",
  }
  $pam_login_attribute = $::openldap::client::pam_login_attribute ? {
    undef   => undef,
    default => "set PAM_LOGIN_ATTRIBUTE ${::openldap::client::pam_login_attribute}",
  }
  $pam_member_attribute = $::openldap::client::pam_member_attribute ? {
    undef   => undef,
    default => "set PAM_MEMBER_ATTRIBUTE ${::openldap::client::pam_member_attribute}",
  }
  $pam_password = $::openldap::client::pam_password ? {
    undef   => undef,
    default => "set PAM_PASSWORD ${::openldap::client::pam_password}",
  }
  $tls_checkpeer = $::openldap::client::tls_checkpeer ? {
    undef   => undef,
    default => "set TLS_CHECKPEER ${::openldap::client::tls_checkpeer}",
  }
  if $::openldap::client::tls_cacert != undef {
    validate_absolute_path($::openldap::client::tls_cacert)
  }
  $tls_cacert = $::openldap::client::tls_cacert ? {
    undef   => undef,
    default => "set TLS_CACERT ${::openldap::client::tls_cacert}",
  }
  if $::openldap::client::tls_cacertdir != undef {
    validate_absolute_path($::openldap::client::tls_cacertdir)
  }
  $tls_cacertdir = $::openldap::client::tls_cacertdir ? {
    undef   => undef,
    default => "set TLS_CACERTDIR ${::openldap::client::tls_cacertdir}",
  }
  $tls_reqcert = $::openldap::client::tls_reqcert ? {
    undef   => undef,
    default => "set TLS_REQCERT ${::openldap::client::tls_reqcert}",
  }
  $sudoers_base = $::openldap::client::sudoers_base ? {
    undef   => undef,
    default => "set SUDOERS_BASE ${::openldap::client::sudoers_base}",
  }
  $changes = delete_undef_values([
    $base,
    $bind_policy,
    $bind_timelimit,
    $binddn,
    $bindpw,
    $ldap_version,
    $scope,
    $ssl,
    $suffix,
    $timelimit,
    $timeout,
    $uri,
    $nss_base_group,
    $nss_base_hosts,
    $nss_base_passwd,
    $nss_base_shadow,
    $pam_filter,
    $pam_login_attribute,
    $pam_member_attribute,
    $pam_password,
    $tls_checkpeer,
    $tls_cacert,
    $tls_cacertdir,
    $tls_reqcert,
    $sudoers_base,
  ])
  augeas { 'ldap.conf':
    incl    => $::openldap::client::file,
    lens    => 'Spacevars.lns',
    changes => $changes,
  }
}
