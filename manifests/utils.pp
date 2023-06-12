# See README.md for details.
class openldap::utils (
  Optional[String[1]] $package         = undef,
  String[1]           $package_version = installed,
) {
  if $package {
    package { $package:
      ensure => $package_version,
    }
  }
}
