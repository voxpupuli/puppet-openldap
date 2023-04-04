# See README.md for details.
class openldap::server::install {
  include openldap::server

  contain openldap::utils

  if $facts['os']['family'] == 'Debian' {
    $policy_rc_d = @(POLICY)
      #!/bin/sh
      if [ "$1" = "slapd" ]; then
        exit 101
      fi
      exit 0
      | POLICY
    file { '/usr/sbin/policy-rc.d':
      ensure  => 'file',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => $policy_rc_d,
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
    ensure       => present,
    responsefile => $responsefile,
  }
}
