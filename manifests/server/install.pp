# See README.md for details.
class openldap::server::install {

  if $::openldap::server::provider == 'olc' {
    $utils_pkg = $::osfamily ? {
      Debian => 'ldap-utils',
      RedHat => 'openldap-clients',
    }

    package { $utils_pkg:
      ensure => present,
    }
  }

  if $::osfamily == 'Debian' {
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('openldap/preseed.erb'),
      before  => Package[$::openldap::server::package],
    }
  }

  $responsefile = $::osfamily ? {
    Debian => '/var/cache/debconf/slapd.preseed',
    RedHat => undef,
  }

  package { $::openldap::server::package:
    ensure       => present,
    responsefile => $responsefile,
  }
}
