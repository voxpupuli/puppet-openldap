# See README.md for details.
class openldap::client::config {
  file { $openldap::client::file:
    ensure  => file,
    content => epp('openldap/ldap.conf.epp'),
  }
}
