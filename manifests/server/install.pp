# See README.md for details.
class openldap::server::install {

  if $::openldap::server::provider == 'olc' {
    $utils_pkg = $::osfamily ? {
      Debian => 'ldap-utils',
      RedHat => 'openldap-clients',
    }

    ensure_packages([$utils_pkg])
  }

  if $::osfamily == 'Debian' {
    $suffix =  size(keys($::openldap::server::databases)) ? {
      1       => join(keys($::openldap::server::databases), ''),
      default => $::openldap::server::default_database,
    }
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
