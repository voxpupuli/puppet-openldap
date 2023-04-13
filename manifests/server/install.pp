# See README.md for details.
class openldap::server::install {
  include openldap::server

  contain openldap::utils

  if $facts['os']['family'] == 'Debian' {
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => "slapd slapd/domain\tstring\tmy-domain.com\n",
      before  => Package[$openldap::server::package],
    }
    $responsefile = '/var/cache/debconf/slapd.preseed'
  } else {
    $responsefile = undef
  }

  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '9') >= 0 {
    if $openldap::server::manage_epel {
      include epel
      Class['epel'] -> Package[$openldap::server::package]
    }
  }

  package { $openldap::server::package:
    ensure       => present,
    responsefile => $responsefile,
  }
}
