# See README.md for details.
class openldap::server::slapdconf {
  include openldap::server

  if $openldap::server::ssl_cert {
    if $openldap::server::ssl_key {
      openldap::server::globalconf { 'TLSCertificate':
        value => {
          'TLSCertificateFile'    => $openldap::server::ssl_cert,
          'TLSCertificateKeyFile' => $openldap::server::ssl_key,
        },
      }
      if $openldap::server::ssl_ca {
        openldap::server::globalconf { 'TLSCACertificateFile':
          value => $openldap::server::ssl_ca,
        }
      }
    } else {
      fail 'You must specify a ssl_key'
    }
  } elsif $openldap::server::ssl_key {
    fail 'You must specify a ssl_cert'
  }

  if $facts['os']['family'] == 'RedHat' {
    openldap::server::database { 'dc=my-domain,dc=com':
      ensure => absent,
    }
  }

  create_resources('openldap::server::database', $openldap::server::databases)
}
