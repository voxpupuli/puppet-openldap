# See README.md for details.
class openldap::server::slapdconf {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  if $::openldap::server::provider == 'augeas' {
    $ensure = $::openldap::server::ensure ? {
      present => present,
      default => absent,
    }
    file { $::openldap::server::file:
      ensure => $ensure,
      owner  => $::openldap::server::owner,
      group  => $::openldap::server::group,
      mode   => '0640',
    }
  }

  if ($::openldap::server::ssl) and ($::openldap::server::ensure == present) {
    validate_absolute_path($::openldap::server::ssl_cert)
    validate_absolute_path($::openldap::server::ssl_key)
    openldap::server::globalconf { 'TLSCertificateFile':
      value => $::openldap::server::ssl_cert,
    }
    ->
    openldap::server::globalconf { 'TLSCertificateKeyFile':
      value => $::openldap::server::ssl_key,
    }
    if $::openldap::server::ssl_ca {
      validate_absolute_path($::openldap::server::ssl_ca)
      openldap::server::globalconf { 'TLSCACertificateFile':
        value => $::openldap::server::ssl_ca,
      }
    }
  }

  if $::osfamily == 'RedHat' and $::openldap::server::suffix != 'dc=my-domain,dc=com' {
    openldap::server::database { 'dc=my-domain,dc=com':
      ensure    => absent,
      directory => '/var/lib/ldap',
    }
  }

  $databases = pick(
    $::openldap::server::databases,
    hash( [ $::openldap::server::suffix, { directory => '/var/lib/ldap', }, ] )
  )

  create_resources('openldap::server::database', $databases)

}
