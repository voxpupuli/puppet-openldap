# See README.md for details.
class openldap::params {
  case $::osfamily {
    'Debian': {
      $client_package           = $::osfamily ? {
        Debian => 'libldap-2.4-2',
        RedHat => 'openldap',
      }
      $client_conffile          = $::osfamily ? {
        Debian => '/etc/ldap/ldap.conf',
        RedHat => '/etc/openldap/ldap.conf',
      }
      $server_confdir           = '/etc/ldap/slapd.d'
      $server_conffile          = '/etc/ldap/slapd.conf'
      $server_group             = 'openldap'
      $server_owner             = 'openldap'
      $server_package           = 'slapd'
      $server_service           = 'slapd'
      $server_service_hasstatus = $::operatingsystemmajrelease ? {
        '5'     => false,
        default => true,
      }
    }
    'RedHat': {
      $client_package           = 'openldap-clients'
      $client_conffile          = '/etc/openldap/ldap.conf'
      $server_confdir           = '/etc/openldap/slapd.d'
      $server_conffile          = '/etc/openldap/slapd.conf'
      $server_group             = 'ldap'
      $server_owner             = 'ldap'
      $server_package           = 'openldap-servers'
      $server_service           = $::operatingsystemmajrelease ? {
        '5' => 'ldap',
        '6' => 'slapd',
        '7' => 'slapd',
      }
      $server_service_hasstatus = true
    }
    default: {
      fail "Operating System family ${::osfamily} not supported"
    }
  }
}
