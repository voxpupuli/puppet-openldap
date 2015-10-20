define openldap::server::access_wrapper (
  $hash,
) {
  $position = $hash[$name]['position']
  $what     = $hash[$name]['what']
  $by       = $hash[$name]['by']
  $access   = $hash[$name]['access']
  $suffix   = $hash[$name]['suffix']
  $count    = count($hash)-1

  if $position == 0 {  # the first entry

    openldap::server::access { "to ${what} by ${by} on ${suffix}" :
      what     => $what,
      by       => $by,
      access   => $access,
      position => $position,
      suffix   => $suffix,
    }

  } elsif $position == $count { #the last entry

    openldap::server::access { "to ${what} by ${by} on ${suffix}" :
      what     => $what,
      by       => $by,
      access   => $access,
      position => $position,
      suffix   => $suffix,
      islast   => true,
    }

    $last_position = $position - 1
    Openldap::Server::Access <| position == $last_position |> -> Openldap::Server::Access <| position == $position |>

  } else {

    openldap::server::access { "to ${what} by ${by} on ${suffix}" :
      what     => $what,
      by       => $by,
      access   => $access,
      position => $position,
      suffix   => $suffix,
    }

    $last_position = $position - 1
    Openldap::Server::Access <| position == $last_position |> -> Openldap::Server::Access <| position == $position |>

  }
}