# See README.md for details.
class openldap::client::config {
  Augeas {
    incl    => $::openldap::client::file,
    lens    => 'Spacevars.lns',
    context => "/files${::openldap::client::file}",
  }
  if $::openldap::client::base != undef {
    augeas { 'ldap.conf+base':
      changes => "set BASE ${::openldap::client::base}",
    }
  }
  if $::openldap::client::bind_policy != undef {
    augeas { 'ldap.conf+bind_policy':
      changes  => "set BIND_POLICY ${::openldap::client::bind_policy}",
    }
  }
  if $::openldap::client::ldap_version != undef {
    augeas { 'ldap.conf+ldap_version':
      changes  => "set LDAP_VERSION ${::openldap::client::ldap_version}",
    }
  }
  if $::openldap::client::scope != undef {
    augeas { 'ldap.conf+scope':
      changes  => "set SCOPE ${::openldap::client::scope}",
    }
  }
  if $::openldap::client::ssl != undef {
    augeas { 'ldap.conf+ssl':
      changes  => "set SSL ${::openldap::client::ssl}",
    }
  }
  if $::openldap::client::suffix != undef {
    augeas { 'ldap.conf+suffix':
      changes  => "set SUFFIX ${::openldap::client::suffix}",
    }
  }
  if $::openldap::client::uri != undef {
    $_uri = join(flatten([$::openldap::client::uri]), ' ')
    augeas { 'ldap.conf+uri':
      changes => "set URI '${_uri}'",
    }
  }
  if $::openldap::client::nss_base_group != undef {
    augeas { 'ldap.conf+nss_base_group':
      changes  => "set NSS_BASE_GROUP ${::openldap::client::nss_base_group}",
    }
  }
  if $::openldap::client::nss_base_hosts != undef {
    augeas { 'ldap.conf+nss_base_hosts':
      changes  => "set NSS_BASE_HOSTS ${::openldap::client::nss_base_hosts}",
    }
  }
  if $::openldap::client::nss_base_passwd != undef {
    augeas { 'ldap.conf+nss_base_passwd':
      changes  => "set NSS_BASE_PASSWD ${::openldap::client::nss_base_passwd}",
    }
  }
  if $::openldap::client::nss_base_shadow != undef {
    augeas { 'ldap.conf+nss_base_shadow':
      changes  => "set NSS_BASE_SHADOW ${::openldap::client::nss_base_shadow}",
    }
  }
  if $::openldap::client::pam_filter != undef {
    augeas { 'ldap.conf+pam_filter':
      changes  => "set PAM_FILTER ${::openldap::client::pam_filter}",
    }
  }
  if $::openldap::client::pam_login_attribute != undef {
    augeas { 'ldap.conf+pam_login_attribute':
      changes  => "set PAM_LOGIN_ATTRIBUTE ${::openldap::client::pam_login_attribute}",
    }
  }
  if $::openldap::client::pam_member_attribute != undef {
    augeas { 'ldap.conf+pam_member_attribute':
      changes  => "set PAM_MEMBER_ATTRIBUTE ${::openldap::client::pam_member_attribute}",
    }
  }
  if $::openldap::client::pam_password != undef {
    augeas { 'ldap.conf+pam_password':
      changes  => "set PAM_PASSWORD ${::openldap::client::pam_password}",
    }
  }
  if $::openldap::client::tls_checkpeer != undef {
    augeas { 'ldap.conf+tls_checkpeer':
      changes  => "set TLS_CHECKPEER ${::openldap::client::tls_checkpeer}",
    }
  }
  if $::openldap::client::tls_cacert != undef {
    validate_absolute_path($::openldap::client::tls_cacert)
    augeas { 'ldap.conf+tls_cacert':
      changes  => "set TLS_CACERT ${::openldap::client::tls_cacert}",
    }
  }
  if $::openldap::client::tls_cacertdir != undef {
    validate_absolute_path($::openldap::client::tls_cacertdir)
    augeas { 'ldap.conf+tls_cacertdir':
      changes  => "set TLS_CACERTDIR ${::openldap::client::tls_cacertdir}",
    }
  }
  if $::openldap::client::tls_reqcert != undef {
    augeas { 'ldap.conf+tls_reqcert':
      changes  => "set TLS_REQCERT ${::openldap::client::tls_reqcert}",
    }
  }
}
