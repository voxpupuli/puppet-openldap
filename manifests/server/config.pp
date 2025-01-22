# See README.md for details.
class openldap::server::config {
  include openldap::server

  $slapd_path          = $openldap::server::slapd_path
  $slapd_params        = $openldap::server::slapd_params
  $owner               = $openldap::server::owner
  $group               = $openldap::server::group
  $enable_chown        = $openldap::server::enable_chown
  $ldap_port           = $openldap::server::ldap_port
  $ldap_address        = $openldap::server::ldap_address
  $ldaps_port          = $openldap::server::ldaps_port
  $ldaps_address       = $openldap::server::ldaps_address
  $ldapi_socket_path   = $openldap::server::ldapi_socket_path
  $register_slp        = $openldap::server::register_slp
  $krb5_keytab_file    = $openldap::server::krb5_keytab_file
  $krb5_client_keytab_file = $openldap::server::krb5_client_keytab_file
  $ldap_config_backend = $openldap::server::ldap_config_backend
  $enable_memory_limit = $openldap::server::enable_memory_limit

  $slapd_ldap_ifs = empty($openldap::server::ldap_ifs) ? {
    false => join(prefix($openldap::server::ldap_ifs, 'ldap://'), ' '),
    true  => '',
  }
  $escaped_ldapi_ifs = $openldap::server::escape_ldapi_ifs ? {
    true  => regsubst($openldap::server::ldapi_ifs, '/', '%2F', 'G'),
    false => $openldap::server::ldapi_ifs,
  }
  $slapd_ldapi_ifs = empty($openldap::server::ldapi_ifs) ? {
    false => join(prefix($escaped_ldapi_ifs, 'ldapi://'), ' '),
    true  => '',
  }
  $slapd_ldaps_ifs = empty($openldap::server::ldaps_ifs) ? {
    false  => join(prefix($openldap::server::ldaps_ifs, 'ldaps://'), ' '),
    true => '',
  }
  $slapd_ldap_urls = "${slapd_ldap_ifs} ${slapd_ldapi_ifs} ${slapd_ldaps_ifs}"

  file { $openldap::server::confdir:
    ensure => directory,
    owner  => $openldap::server::owner,
    group  => $openldap::server::group,
    mode   => '0750',
    force  => true,
  }

  case $facts['os']['family'] {
    'Debian': {
      shellvar { 'slapd':
        ensure   => present,
        target   => '/etc/default/slapd',
        variable => 'SLAPD_SERVICES',
        value    => $slapd_ldap_urls,
      }
      if $krb5_keytab_file {
        shellvar { 'krb5_ktname':
          ensure   => exported,
          target   => '/etc/default/slapd',
          variable => 'KRB5_KTNAME',
          value    => $krb5_keytab_file,
        }
      }
      if $krb5_client_keytab_file {
        shellvar { 'krb5_client_ktname':
          ensure   => exported,
          target   => '/etc/default/slapd',
          variable => 'KRB5_CLIENT_KTNAME',
          value    => $krb5_client_keytab_file,
        }
      }
      # Debian configuration include database creation. We skip this with
      # preseeding files so we need to manualy bootstrap cn=config (but not the
      # databases).
      exec { 'bootstrap cn=config':
        command  => "/bin/sed -e 's/@BACKEND@/mdb/g' -e '/^# The database definition.$/q' /usr/share/slapd/slapd.init.ldif | /usr/sbin/slapadd -F ${openldap::server::confdir} -b cn=config",
        provider => 'shell',
        creates  => "${openldap::server::confdir}/cn=config.ldif",
        user     => $openldap::server::owner,
        group    => $openldap::server::group,
        require  => File[$openldap::server::confdir],
      }
    }
    'RedHat': {
      if versioncmp($facts['os']['release']['major'], '6') <= 0 {
        $ldap = empty($openldap::server::ldap_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAP':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAP',
          value    => $ldap,
        }
        $ldaps = empty($openldap::server::ldaps_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPS':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPS',
          value    => $ldaps,
        }
        $ldapi = empty($openldap::server::ldapi_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPI':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPI',
          value    => $ldapi,
        }
      } else {
        shellvar { 'slapd':
          ensure   => present,
          target   => '/etc/sysconfig/slapd',
          variable => 'SLAPD_URLS',
          value    => $slapd_ldap_urls,
        }
      }
      if versioncmp($facts['os']['release']['major'], '8') >= 0 {
        if $slapd_path != undef {
          $real_slapd_path = $slapd_path
        } else {
          $real_slapd_path = '/usr/sbin/slapd'
        }
        systemd::dropin_file { 'puppet.conf':
          unit    => "${openldap::server::service}.service",
          content => join([
              '[Service]',
              'EnvironmentFile=/etc/sysconfig/slapd',
              'ExecStart=',
              "ExecStart=${real_slapd_path} -u ${openldap::server::owner} -h \${SLAPD_URLS} \$SLAPD_OPTIONS",
          ], "\n"),
        }
      }
    }
    'Archlinux': {}
    'FreeBSD': {
      shellvar { 'slapd_cn_config':
        ensure   => present,
        target   => '/etc/rc.conf',
        variable => 'slapd_cn_config',
        value    => 'YES',
        quoted   => 'double',
      }

      shellvar { 'slapd_flags':
        ensure   => present,
        target   => '/etc/rc.conf',
        variable => 'slapd_flags',
        value    => "-h '${slapd_ldap_urls}'",
        quoted   => 'double',
      }

      $slapd_sockets_ensure = bool2str(empty($openldap::server::ldapi_ifs), 'absent', 'present')
      shellvar { 'slapd_sockets':
        ensure   => $slapd_sockets_ensure,
        target   => '/etc/rc.conf',
        variable => 'slapd_sockets',
        value    => join($openldap::server::ldapi_ifs, ' '),
        quoted   => 'double',
      }

      # On FreeBSD we need to bootstrap slapd.d
      $ldif = file('openldap/cn-config.ldif')
      exec { 'bootstrap cn=config':
        path     => '/usr/local/sbin',
        command  => "echo '${ldif}' | slapadd -n 0 -F ${openldap::server::confdir}",
        creates  => "${openldap::server::confdir}/cn=config.ldif",
        provider => 'shell',
        user     => $openldap::server::owner,
        group    => $openldap::server::group,
        require  => File[$openldap::server::confdir],
      }
    }
    'Suse': {
      $start_ldap = empty($openldap::server::ldap_ifs) ? {
        false  => 'yes',
        true   => 'no',
      }
      $start_ldapi = empty($openldap::server::ldapi_ifs) ? {
        false  => 'yes',
        true   => 'no',
      }
      $start_ldaps = empty($openldap::server::ldaps_ifs) ? {
        false  => 'yes',
        true   => 'no',
      }
      if $slapd_params != undef {
        $real_slapd_params = $slapd_params
      } else {
        $real_slapd_params = ''
      }
      $real_enable_chown = bool2str($enable_chown, 'yes', 'no')
      if ($ldap_address != undef and $ldap_port != undef) {
        $ldap_interface = "${ldap_address}:${ldap_port}"
      } else {
        $ldap_interface = ''
      }
      if ($ldaps_address != undef and $ldaps_port != undef) {
        $ldaps_interface = "${ldaps_address}:${ldaps_port}"
      } else {
        $ldaps_interface = ''
      }
      if $ldapi_socket_path != undef {
        $ldapi_interface = $ldapi_socket_path
      } else {
        $ldapi_interface = ''
      }
      $real_slp = bool2str($register_slp, 'yes', 'no')
      if $krb5_keytab_file != undef {
        $real_krb5_keytab_file = $krb5_keytab_file
      } else {
        $real_krb5_keytab_file = ''
      }
      $real_enable_memory_limit = bool2str($enable_memory_limit, 'yes', 'no')

      shellvar { 'OPENLDAP_START_LDAP':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_START_LDAP',
        value    => $start_ldap,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_START_LDAPS':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_START_LDAPS',
        value    => $start_ldaps,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_START_LDAPI':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_START_LDAPI',
        value    => $start_ldapi,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_SLAPD_PARAMS':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_SLAPD_PARAMS',
        value    => $real_slapd_params,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_USER':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_USER',
        value    => $owner,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_GROUP':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_GROUP',
        value    => $group,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_CHOWN_DIRS':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_CHOWN_DIRS',
        value    => $real_enable_chown,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_LDAP_INTERFACES':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_LDAP_INTERFACES',
        value    => $ldap_interface,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_LDAPS_INTERFACES':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_LDAPS_INTERFACES',
        value    => $ldaps_interface,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_LDAPI_INTERFACES':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_LDAPI_INTERFACES',
        value    => $ldapi_interface,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_REGISTER_SLP':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_REGISTER_SLP',
        value    => $real_slp,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_KRB5_KEYTAB':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_KRB5_KEYTAB',
        value    => $real_krb5_keytab_file,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_CONFIG_BACKEND':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_CONFIG_BACKEND',
        value    => $ldap_config_backend,
        quoted   => 'double',
      }
      shellvar { 'OPENLDAP_MEMORY_LIMIT':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_MEMORY_LIMIT',
        value    => $real_enable_memory_limit,
        quoted   => 'double',
      }
    }
    default: {
      fail "Operating System Family ${facts['os']['family']} not yet supported"
    }
  }
}
