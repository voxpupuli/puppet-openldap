# See README.md for details.
class openldap::server::slapdconf {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  case $::openldap::server::provider {
    'augeas': {
      file { $::openldap::server::conffile:
        ensure => file,
        owner  => $::openldap::server::owner,
        group  => $::openldap::server::group,
        mode   => '0640',
      }
    }
    'olc': {
      file { $::openldap::server::confdir:
        ensure => directory,
        owner  => $::openldap::server::owner,
        group  => $::openldap::server::group,
        mode   => '0750',
        force  => true,
      }
    }
    default: {
      fail 'provider must be one of "olc" or "augeas"'
    }
  }

  if $::openldap::server::ssl_cert and empty($::openldap::server::ssl_key) {
    fail 'You must specify a ssl_cert'
  }

  $has_ca = ! empty($::openldap::server::ssl_ca)
  $has_key = ! empty($::openldap::server::ssl_key)


  if $::openldap::server::ssl_cert {
    if ! $has_key {
      fail 'You must specify a ssl_key'
    }

    validate_absolute_path($::openldap::server::ssl_cert)
    validate_absolute_path($::openldap::server::ssl_key)

    if $has_ca {
      validate_absolute_path($::openldap::server::ssl_ca)

      $tls_settings = {
        'TLSCertificateFile'    => $::openldap::server::ssl_cert,
        'TLSCertificateKeyFile' => $::openldap::server::ssl_key,
        'TLSCACertificateFile'  => $::openldap::server::ssl_ca,
      }
    } else {
      $tls_settings = {
          'TLSCertificateFile'    => $::openldap::server::ssl_cert,
          'TLSCertificateKeyFile' => $::openldap::server::ssl_key,
      }
    }

    openldap::server::config_hash { 'TLS Settings':
      value => $tls_settings,
    }
  }

  openldap::server::database { 'dc=my-domain,dc=com':
    ensure => absent,
  }

  create_resources('openldap::server::database', $::openldap::server::databases)

}
