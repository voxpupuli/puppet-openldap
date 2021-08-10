package { 'ssl-cert':
  ensure => installed,
}
file { '/etc/ldap':
  ensure => directory,
}
file { '/etc/ldap/ssl':
  ensure => directory,
}
file { "/etc/ldap/ssl/${::fqdn}.key":
  ensure  => file,
  mode    => '0644',
  source  => "/etc/ssl/private/ssl-cert-snakeoil.key",
}
file { "/etc/ldap/ssl/${::fqdn}.crt":
  ensure  => file,
  mode    => '0644',
  source  => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
}
file { '/etc/ldap/ssl/ca.pem':
  ensure  => file,
  mode    => '0644',
  source  => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
}
