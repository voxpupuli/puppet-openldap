class openldap::client::config {
  Shellvar {
    ensure   => present,
    target   => $::openldap::client::file,
  }
  if $::openldap::client::base{
    shellvar { 'ldap.conf+base':
      variable => 'BASE',
      value    => $::openldap::client::base,
    }
  }
  if $::openldap::client::uri {
    shellvar { 'ldap.conf+uri':
      variable => 'URI',
      value    => $::openldap::client::uri,
    }
  }
  if $::openldap::client::tls_cacert {
    shellvar { 'ldap.conf+tls_cacert':
      variable => 'TLS_CACERT',
      value    => $::openldap::client::tls_cacert,
    }
  }
}
