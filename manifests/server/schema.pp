# See README.md for details.
define openldap::server::schema (
  Optional[Enum['present', 'absent']] $ensure = undef,
  Stdlib::Absolutepath                $path   = $facts['os']['family'] ? {
    'Debian' => "/etc/ldap/schema/${title}.schema",
    'Redhat' => "/etc/openldap/schema/${title}.schema",
    'Archlinux' => "/etc/openldap/schema/${title}.schema",
    'FreeBSD' => "/usr/local/etc/openldap/schema/${title}.schema",
    'Suse' => "/etc/openldap/schema/${title}.schema",
  }
) {
  include openldap::server

  Class['openldap::server::service']
  -> Openldap::Server::Schema[$title]
  -> Class['openldap::server']
  openldap_schema { $title:
    ensure => $ensure,
    path   => $path,
  }
}
