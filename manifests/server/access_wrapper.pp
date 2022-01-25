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
#   Mandatory. Array of Hash in the form { <what> => <access>, ... }
#
#   example:
#     $acl = [
#       {
#         'to *'                       => [
#           'by dn.base="cn=replicator,dc=suretecsystems,dc=com" write',
#           'by * break'
#         ],
#       },
#       {
#         'to dn.base=""'              => [
#           'by * read',
#         ],
#       },
#       {
#         'to dn.base="cn=Subschema"'  => [
#           'by * read',
#         ],
#       },
#       {
#         'to dn.subtree="cn=Monitor"' => [
#           'by dn.exact="uid=admin,dc=suretecsystems,dc=com" write',
#           'by users read',
#           'by * none',
#         ],
#       },
#       {
#         'to *'                       => [
#           'by self write',
#           'by * none',
#         ]
#       },
#     ]
#
define openldap::server::access_wrapper (
  Array[Hash[Pattern[/\Ato\s/], Array[Openldap::Access_rule], 1, 1]] $acl,
  String[1] $suffix = $name,
) {
  # Parse ACL
  # lint:ignore:strict_indent
  $acl_yaml = inline_template(@("RUBY"))
    <%=
      position = -1
      @acl.map do |acl|
        acl.map do |to, access|
          position = position + 1
          {
            "#{position} on #{@suffix}" => {
              "position" => position,
              "what"     => to[/\Ato (.*)/, 1],
              "access"   => access,
              "suffix"   => "#{@suffix}",
            }
          }
        end
      end.flatten.reduce({}, :update).to_yaml
    %>
    | RUBY
  # lint:endignore

  $hash = parseyaml($acl_yaml)
  $hash_keys = keys($hash)

  openldap::server::iterate_access { $hash_keys :
    hash => $hash,
  }
}
