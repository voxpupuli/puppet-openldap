# See README.md for details.
define openldap::client::conf (
  $ensure = present,
  $value  = undef,
) {
  include openldap::client

  if ! ($ensure in [ present, absent ]) {
    fail("'${ensure}' is not a valid ensure parameter value")
  }

  if is_array($value) {
    $value_flattened = join(flatten([$value]), ' ')
    $value_real = "'${value_flattened}'"
  } elsif is_integer($value) {
    $value_real = $value
  } else {
    validate_string($value)
    $value_real = $value
  }

  $name_real = downcase($name)
  $param     = upcase($name)

  if $ensure == present {
    $onlyif  = "match ${param}[.='${value_real}'] size == 0"
    $changes = "set ${param} ${value_real}"
  } else {
    $onlyif  = "match ${param} size != 0"
    $changes = "rm ${param}"
  }

  augeas { "ldap.conf+${name_real}":
    incl    => $::openldap::client::file,
    lens    => 'Spacevars.lns',
    context => "/files${::openldap::client::file}",
    onlyif  => $onlyif,
    changes => $changes,
  }

}
