# See README.md for details.
class openldap::server::install {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'olc' {
    include ::openldap::utils
  }

  if $::osfamily == 'Debian' {
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => "slapd slapd/domain\tstring\tmy-domain.com\n",
      before  => Package[$::openldap::server::package],
    }
  }

  $responsefile = $::osfamily ? {
    'Debian' => '/var/cache/debconf/slapd.preseed',
    'RedHat' => undef,
  }

  package { $::openldap::server::package:
    ensure       => present,
    responsefile => $responsefile,
  }
}
