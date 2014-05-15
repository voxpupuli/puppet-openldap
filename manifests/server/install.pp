# See README.md for details.
class openldap::server::install {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if ($::openldap::server::ensure == present) or (defined(Class['openldap::client']) and ($::openldap::client::ensure == present)) {
    $pkg_ensure = present
  } else {
    $pkg_ensure = purged
  }

  if $::openldap::server::provider == 'olc' {
    $utils_pkg = $::osfamily ? {
      Debian => 'ldap-utils',
      RedHat => 'openldap-clients',
    }

    package { [$utils_pkg]:
      ensure => $pkg_ensure,
    }
  }

  if $::osfamily == 'Debian' {
    $suffix =  size(keys($::openldap::server::databases)) ? {
      1       => join(keys($::openldap::server::databases), ''),
      default => $::openldap::server::default_database,
    }
    $ensure = $::openldap::server::ensure ? {
      present => present,
      default => absent
    }
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => $ensure,
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
    ensure       => $::openldap::server::ensure,
    responsefile => $responsefile,
  }
}
