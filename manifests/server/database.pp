# See README.md for details.
define openldap::server::database (
  Enum['present', 'absent']                           $ensure            = present,
  Optional[Stdlib::Absolutepath]                      $directory         = undef,
  String[1]                                           $suffix            = $title,
  Optional[String[1]]                                 $relay             = undef,
  Optional[String[1]]                                 $backend           = undef,
  Optional[Variant[Sensitive[String],String[1]]]      $rootdn            = undef,
  Optional[Variant[Sensitive[String],String[1]]]      $rootpw            = undef,
  Optional[Boolean]                                   $initdb            = undef,
  Boolean                                             $readonly          = false,
  Optional[String[1]]                                 $sizelimit         = undef,
  Optional[String[1]]                                 $dbmaxsize         = undef,
  Optional[String[1]]                                 $timelimit         = undef,
  Optional[String[1]]                                 $updateref         = undef,
  Optional[Boolean]                                   $lastbind          = undef,
  Optional[Integer[0]]                                $lastbindprecision = undef,
  Openldap::Limits                                    $limits            = {},
  # BDB/HDB options
  Hash[String[1],Variant[String[1],Array[String[1]]]] $dboptions         = {},
  Optional[String[1]]                                 $synctype          = undef,
  # Synchronization options
  Optional[Boolean]                                   $mirrormode        = undef,
  Optional[Boolean]                                   $multiprovider     = undef,
  Optional[String[1]]                                 $syncusesubentry   = undef,
  Array[Openldap::Syncrepl]                           $syncrepl          = [],
  Hash[
    Enum[
      'transport',
      'sasl',
      'simple_bind',
      'ssf',
      'tls',
      'update_sasl',
      'update_ssf',
      'update_tls',
      'update_transport',
    ],
    Integer[0]
  ]                                                   $security        = {},
) {
  include openldap::server

  if $mirrormode != undef and $multiprovider != undef {
    warning('multiprovider is an openldap2.5+ replacement for mirrormode.')
  }

  $manage_directory = $backend ? {
    'monitor' => undef,
    'config'  => undef,
    'relay'   => undef,
    'ldap'    => undef,
    default   => $directory.lest || { $openldap::server::default_directory },
  }

  Class['openldap::server::service']
  -> Openldap::Server::Database[$title]
  -> Class['openldap::server']
  if $title != 'dc=my-domain,dc=com' and fact('os.family') == 'RedHat' {
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
    ensure            => $ensure,
    suffix            => $suffix,
    relay             => $relay,
    target            => $openldap::server::conffile,
    backend           => $backend,
    directory         => $manage_directory,
    rootdn            => $rootdn,
    rootpw            => $rootpw,
    initdb            => $initdb,
    readonly          => $readonly,
    sizelimit         => $sizelimit,
    timelimit         => $timelimit,
    dbmaxsize         => $dbmaxsize,
    updateref         => $updateref,
    lastbind          => $lastbind,
    lastbindprecision => $lastbindprecision,
    dboptions         => $dboptions,
    synctype          => $synctype,
    mirrormode        => $mirrormode,
    multiprovider     => $multiprovider,
    syncusesubentry   => $syncusesubentry,
    syncrepl          => $syncrepl.map |$item| {
      $item.map |$k, $v| {
        $v ? {
          true    => $k,
          false   => undef,
          default => "${k}=${String($v, '%#p')}",
        }
      }.flatten.join(' ')
    },
    limits            => $limits.map |$selector, $limits| { "${selector} ${limits.map |$k, $v| { "${k}=${v}" }.join(' ')}" },
    security          => $security,
  }
}
