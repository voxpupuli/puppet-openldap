class openldap::client::config {
  file { $::openldap::client::file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openldap/ldap.conf.erb'),
  }
}
