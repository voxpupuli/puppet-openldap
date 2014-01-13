# See README.md for details.
class openldap::client::config {
  Shellvar {
    ensure   => present,
    target   => $::openldap::client::file,
  }
  if $::openldap::client::base != undef {
    shellvar { 'ldap.conf+base':
      variable => 'BASE',
      value    => $::openldap::client::base,
    }
  }
  if $::openldap::client::uri != undef {
    shellvar { 'ldap.conf+uri':
      variable   => 'URI',
      array_type => 'string',
      value      => $::openldap::client::uri,
    }
  }
  if $::openldap::client::tls_cacert != undef {
    validate_absolute_path($::openldap::client::tls_cacert)
    shellvar { 'ldap.conf+tls_cacert':
      variable => 'TLS_CACERT',
      value    => $::openldap::client::tls_cacert,
    }
  }
}
