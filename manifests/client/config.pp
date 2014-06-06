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
  if $::openldap::client::uri != undef {
    $_uri = join(flatten([$::openldap::client::uri]), ' ')
    augeas { 'ldap.conf+uri':
      changes => "set URI '${_uri}'",
    }
  }
  if $::openldap::client::tls_cacert != undef {
    validate_absolute_path($::openldap::client::tls_cacert)
    augeas { 'ldap.conf+tls_cacert':
      changes  => "set TLS_CACERT ${::openldap::client::tls_cacert}"
    }
  }
}
