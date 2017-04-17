# See README.md for details.
class openldap::client::install {

  if ! defined(Class['openldap::client']) {
    fail 'class ::openldap::client has not been evaluated'
  }

  case $::osfamily {
    'Debian': {
      package { $::openldap::client::package:
        ensure => present,
      }
    }
    'RedHat': {
      include ::openldap::client::utils
    }
    default: {
      fail "Operating System family ${::osfamily} not supported"
    }
  }
}
