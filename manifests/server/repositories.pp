# See README.md for details.
class openldap::server::repositories {
  if $::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '8') >= 0 {
    yumrepo { 'PowerTools':
      enabled => '1',
    }
  }
}
