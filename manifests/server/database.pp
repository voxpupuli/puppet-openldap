# See README.md for details.
define openldap::server::database (
  Enum['present', 'absent']                     $ensure          = present,
  Optional[Stdlib::Absolutepath]                $directory       = undef,
  String[1]                                     $suffix          = $title,
  Optional[String[1]]                           $relay           = undef,
  Optional[String[1]]                           $backend         = undef,
  Optional[String[1]]                           $rootdn          = undef,
  Optional[String[1]]                           $rootpw          = undef,
  Optional[String[1]]                           $initdb          = undef,
  Boolean                                       $readonly        = false,
  Optional[String[1]]                           $sizelimit       = undef,
  Optional[String[1]]                           $dbmaxsize       = undef,
  Optional[String[1]]                           $timelimit       = undef,
  Optional[String[1]]                           $updateref       = undef,
  Optional[String[1]]                           $limits          = undef,
  # BDB/HDB options
  Optional[String[1]]                           $dboptions       = undef,
  Optional[String[1]]                           $synctype        = undef,
  # Synchronization options
  Optional[String[1]]                           $mirrormode      = undef,
  Optional[String[1]]                           $syncusesubentry = undef,
  Optional[Variant[String[1],Array[String[1]]]] $syncrepl        = undef,
  Optional[String[1]]                           $security        = undef,
) {
  if ! defined(Class['openldap::server']) {
    fail 'class openldap::server has not been evaluated'
  }

  $manage_directory = $backend ? {
    'monitor' => undef,
    'config'  => undef,
    'relay'   => undef,
    'ldap'    => undef,
    default   => $directory ? {
      undef   => '/var/lib/ldap',
      default => $directory,
    },
  }

  Class['openldap::server::service']
  -> Openldap::Server::Database[$title]
  -> Class['openldap::server']
  if $title != 'dc=my-domain,dc=com' and fact('os.family') == 'Debian' {
    Openldap::Server::Database['dc=my-domain,dc=com'] -> Openldap::Server::Database[$title]
  }

  if $ensure == present and $backend != 'monitor' and $backend != 'config' and $backend != 'relay' and $backend != 'ldap' {
    file { $manage_directory:
      ensure => directory,
      owner  => $openldap::server::owner,
      group  => $openldap::server::group,
      before => Openldap_database[$title],
    }
  }

  openldap_database { $title:
    ensure          => $ensure,
    suffix          => $suffix,
    relay           => $relay,
    target          => $openldap::server::conffile,
    backend         => $backend,
    directory       => $manage_directory,
    rootdn          => $rootdn,
    rootpw          => $rootpw,
    initdb          => $initdb,
    readonly        => $readonly,
    sizelimit       => $sizelimit,
    timelimit       => $timelimit,
    dbmaxsize       => $dbmaxsize,
    updateref       => $updateref,
    dboptions       => $dboptions,
    synctype        => $synctype,
    mirrormode      => $mirrormode,
    syncusesubentry => $syncusesubentry,
    syncrepl        => $syncrepl,
    limits          => $limits,
    security        => $security,
  }
}
