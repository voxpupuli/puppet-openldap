# == Define openldap::server::access_wrapper
#
# Generate access from a given hash.
#
# === Parameters
#
# [*suffix*]
#   Default: $name
#   Mandatory. The suffix to apply acls
#
# [*acl*]
#   Default:
#   Mandatory. Hash in the form { <what> => <access>, ... }
#
#   example:
#     $acl = {
#       'to *' => [
#         'by self write',
#         'by anonymous read',
#       ],
#     }
#
define openldap::server::access_wrapper (
  $acl,
  $suffix = $name,
) {

  # Parse ACL
  $acl_yaml = inline_template('<%=
    position = -1
    acl.map { |to,access|
      position = position + 1
      {
        "#{position} on #{suffix}" => {
          "position" => position,
          "what"     => to[/.*to (.*)/,1],
          "access"   => access,
          "suffix"   => "#{suffix}",
        }
      }
  }.flatten.reduce({}, :update).to_yaml
  %>')

  $hash = parseyaml($acl_yaml)
  $hash_keys = keys($hash)


  # Call individual openldap::server::access
  $position = $hash[$name]['position']
  $what     = $hash[$name]['what']
  $access   = $hash[$name]['access']
  $suffix   = $hash[$name]['suffix']

  $count    = count($hash)-1

  if ! is_array($access) {
    fail('$access variable must be an array')
  }

  if $position == 0 {  # the first entry

    openldap::server::access { "${position} on ${suffix}" :
      what   => $what,
      access => $access,
    }

  } elsif $position == $count { #the last entry

    $previous_position = $position - 1
    openldap::server::access { "${position} on ${suffix}" :
      what    => $what,
      access  => $access,
      islast  => true,
      require => Openldap::Server::Access["${previous_position} on ${suffix}"],
    }

  } else {

    $previous_position = $position - 1
    openldap::server::access { "${position} on ${suffix}" :
      what    => $what,
      access  => $access,
      require => Openldap::Server::Access["${previous_position} on ${suffix}"],
    }

  }
}
