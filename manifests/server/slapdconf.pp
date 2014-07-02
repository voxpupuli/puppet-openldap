# See README.md for details.
class openldap::server::slapdconf {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  case $::openldap::server::provider {
    augeas: {
      $ensure = $::openldap::server::ensure ? {
        present => present,
        default => absent,
      }
      file { $::openldap::server::conffile:
        ensure => $ensure,
        owner  => $::openldap::server::owner,
        group  => $::openldap::server::group,
        mode   => '0640',
      }
    }
    olc: {
      $ensure = $::openldap::server::ensure ? {
        present => directory,
        default => absent,
      }
      file { $::openldap::server::confdir:
        ensure => $ensure,
        owner  => $::openldap::server::owner,
        group  => $::openldap::server::group,
        mode   => '0750',
        force  => true,
      }
    }
  }

  if $::openldap::server::ensure == present {

    if $::openldap::server::ssl_cert {
      if $::openldap::server::ssl_key {
        validate_absolute_path($::openldap::server::ssl_cert)
        validate_absolute_path($::openldap::server::ssl_key)
        openldap::server::globalconf { 'TLSCertificateFile':
          value => $::openldap::server::ssl_cert,
        }
        openldap::server::globalconf { 'TLSCertificateKeyFile':
          value => $::openldap::server::ssl_key,
        }
        if $::openldap::server::ssl_ca {
          validate_absolute_path($::openldap::server::ssl_ca)
          openldap::server::globalconf { 'TLSCACertificateFile':
            value => $::openldap::server::ssl_ca,
          }
        }
      } else {
        fail 'You must specify a ssl_key'
      }
    } elsif $::openldap::server::ssl_key {
      fail 'You must specify a ssl_cert'
    }

    if $::osfamily == 'RedHat'
      and $::openldap::server::suffix != 'dc=my-domain,dc=com'
      and !member(keys($::openldap::server::databases), 'dc=my-domain,dc=com') {
      openldap::server::database { 'dc=my-domain,dc=com':
        ensure    => absent,
      }
    }

    if !empty($::openldap::server::databases)
      and !member(keys($::openldap::server::databases), $::openldap::server::suffix) {
      fail "'${::openldap::server::suffix} should be a key of \$::openldap::server::databases hash"
    }

    if empty($::openldap::server::databases) {
      $databases = hash(
        [ $::openldap::server::suffix, { directory => '/var/lib/ldap', }, ] )
    } else {
      $databases = $::openldap::server::databases
    }

    create_resources('openldap::server::database', $databases)

  }

}
