case $facts['os']['family'] {
  'Debian': {
    $package_name = 'ssl-cert'
    $ssl_key_source = '/etc/ssl/private/ssl-cert-snakeoil.key'
    $ssl_cert_source = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  }
  'RedHat': {
    $package_name = 'mod_ssl'
    $ssl_key_source = '/etc/pki/tls/private/localhost.key'
    $ssl_cert_source = '/etc/pki/tls/certs/localhost.crt'
  }
}
if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '8') >= 0 {
  exec { 'gencerts':
    command     => '/usr/libexec/httpd-ssl-gencerts',
    refreshonly => true,
    subscribe   => Package[$package_name],
    before      => [
      File["/etc/ldap/ssl/${facts['networking']['fqdn']}.key"],
      File["/etc/ldap/ssl/${facts['networking']['fqdn']}.crt"],
    ],
  }
  # EL8+ does not enable repo by default that has openldap-servers
  if versioncmp($facts['os']['release']['major'], '8') == 0 {
    $repo = 'powertools'
  } else {
    $repo = 'crb'
  }
  package { 'dnf-utils':
    ensure => 'installed',
  }
  exec { 'enable-repo':
    command => "/usr/bin/dnf config-manager --set-enabled ${repo}",
    unless  => "/usr/bin/dnf config-manager --dump ${repo} | grep 'enabled = 1'",
    require => Package['dnf-utils'],
  }
}

package { $package_name:
  ensure => installed,
}
file { '/etc/ldap':
  ensure => directory,
}
file { '/etc/ldap/ssl':
  ensure => directory,
}
file { "/etc/ldap/ssl/${facts['networking']['fqdn']}.key":
  ensure  => file,
  mode    => '0644',
  source  => $ssl_key_source,
}
file { "/etc/ldap/ssl/${facts['networking']['fqdn']}.crt":
  ensure  => file,
  mode    => '0644',
  source  => $ssl_cert_source,
}
file { '/etc/ldap/ssl/ca.pem':
  ensure  => file,
  mode    => '0644',
  source  => $ssl_cert_source,
}

# Hack to work around issues with recent systemd and docker with systemd running services as non-root
if $facts['os']['family'] == 'RedHat' {
  file { '/etc/systemd/system/slapd.service.d': ensure => 'directory' }
  file { '/etc/systemd/system/slapd.service.d/z-hack.conf':
    ensure  => 'file',
    content => join([
      '[Service]',
      'User=root',
      'Group=root',
      'ExecStartPre=',
      'ExecStartPre=/usr/bin/chown root:root /var/run/openldap',
      'ExecStart=',
      'ExecStart=/usr/sbin/slapd -u root -h ${SLAPD_URLS} $SLAPD_OPTIONS',
    ], "\n"),
  }
}
