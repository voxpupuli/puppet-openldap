# See README.md for details.
class openldap::client::config {
  if $::openldap::client::base != undef {
    openldap::client::conf { 'BASE':
      ensure => $::openldap::client::ensure,
      value  => $::openldap::client::base,
    }
  }
  if $::openldap::client::uri != undef {
    if is_array($::openldap::client::uri) {
      validate_array($::openldap::client::uri)
    } else {
      validate_string($::openldap::client::uri)
    }

    openldap::client::conf { 'URI':
      ensure => $::openldap::client::ensure,
      value  => $::openldap::client::uri,
    }
  }
  if $::openldap::client::tls_cacert != undef {
    validate_absolute_path($::openldap::client::tls_cacert)
    openldap::client::conf { 'TLS_CACERT':
      ensure => $::openldap::client::ensure,
      value  => $::openldap::client::tls_cacert,
    }
  }
}
