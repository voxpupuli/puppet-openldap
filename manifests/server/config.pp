class openldap::server::config {

  if $::openldap::server::ssl {
    validate_absolute_path($::openldap::server::ssl_cert)
    validate_absolute_path($::openldap::server::ssl_key)
    openldap_global_conf { 'TLSCertificateFile':
      value => $::openldap::server::ssl_cert,
    }
    ->
    openldap_global_conf { 'TLSCertificateKeyFile':
      value => $::openldap::server::ssl_key,
    }
    if $::openldap::server::ssl_ca {
      validate_absolute_path($::openldap::server::ssl_ca)
      openldap_global_conf { 'TLSCACertificateFile':
        value => $::openldap::server::ssl_ca,
      }
    }
  }

  case $::osfamily {
    Debian: {
      $slapd_services = $::openldap::server::ssl ? {
        true  => 'ldap://127.0.0.1:389/ ldaps:/// ldapi:///',
        false => 'ldap://127.0.0.1:389/ ldapi:///',
      }

      shellvar { 'slapd':
        ensure   => present,
        target   => '/etc/default/slapd',
        variable => 'SLAPD_SERVICES',
        value    => $slapd_services,
      }
    }
    default: {
      fail "Operating System Family ${::osfamily} not yet supported"
    }
  }
}
