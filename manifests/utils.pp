# See README.md for details.
class openldap::utils (
  Optional[String[1]] $package = undef,
) {
  if $package {
    package { $package:
      ensure => present,
    }
  }
}
