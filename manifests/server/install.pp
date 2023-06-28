# See README.md for details.
class openldap::server::install {
  include openldap::server

  contain openldap::utils

  if $facts['os']['family'] == 'Debian' {
    # When preseeding request to skip the configuration, the service will not
    # start and the installation will return an error. To avoid this, we mask
    # the unit. The installer will not attempt to start slapd and the
    # installation will succed. The module will then be able to tune slapd
    # accoding to the user needs and finally start (and unmak) the service.
    exec { 'mask-before-openldap-install':
      command => "systemctl mask ${openldap::server::service}",
      unless  => 'test -x /usr/sbin/slapd',
      creates => "/etc/systemd/system/${openldap::server::service}.service",
      path    => '/bin:/usr/bin',
      before  => Package[$openldap::server::package],
    }
    file { '/var/cache/debconf/slapd.preseed':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => "slapd slapd/no_configuration\tboolean\ttrue\n",
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
    ensure       => $openldap::server::package_version,
    responsefile => $responsefile,
  }
}
