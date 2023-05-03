#  This is a 'private' class used by openldap::server::access_wrapper
define openldap::server::iterate_access (
  Openldap::Access_hash $hash,
) {
  # Call individual openldap::server::access
  $position = $hash[$name]['position']
  $what     = $hash[$name]['what']
  $access   = $hash[$name]['access']
  $suffix   = $hash[$name]['suffix']

  $count    = count($hash)-1

  $previous_position = $position - 1

  if $previous_position < 0 {
    $require = []
  } else {
    $require = Openldap::Server::Access["${previous_position} on ${suffix}"]
  }

  openldap::server::access { "${position} on ${suffix}" :
    what    => $what,
    access  => $access,
    require => $require,
  }
}
