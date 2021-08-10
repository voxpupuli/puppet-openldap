# See README.md for details.
class openldap::utils (
  Optional[String[1]] $package,
) {
  if $package {
    package { $package:
      ensure => present,
    }
  }
}
