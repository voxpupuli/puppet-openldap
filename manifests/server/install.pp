# See README.md for details.
class openldap::server::install {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'olc' {
    include ::openldap::client::utils
  }

  if $::osfamily == 'Debian' {
    $content = $::openldap::server::ensure ? {
      present => template('openldap/preseed.erb'),
      default => undef,
    }
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => $::openldap::server::ensure,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => $content,
      before  => Package[$::openldap::server::package],
    }
  }

  $responsefile = $::osfamily ? {
    Debian => '/var/cache/debconf/slapd.preseed',
    RedHat => undef,
  }

  $ensure = $::openldap::server::ensure ? {
    present => present,
    default => $::osfamily ? {
      Debian => purged,
      RedHat => absent,
    },
  }

  package { $::openldap::server::package:
    ensure       => $ensure,
    responsefile => $responsefile,
  }
}
