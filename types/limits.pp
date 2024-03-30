# @summary Limits for clients
#
# @see https://www.openldap.org/doc/admin26/limits.html
type Openldap::Limits = Hash[
  String[1],
  Struct[
    {
      # Specify time limits
      Optional['time']           => Variant[Integer[0], Enum['unlimited']],
      Optional['time.soft']      => Variant[Integer[0], Enum['unlimited']],
      Optional['time.hard']      => Variant[Integer[0], Enum['unlimited']],
      # Specifying size limits
      Optional['size']           => Variant[Integer[0], Enum['unlimited']],
      Optional['size.soft']      => Variant[Integer[0], Enum['unlimited']],
      Optional['size.hard']      => Variant[Integer[0], Enum['unlimited']],
      Optional['size.unchecked'] => Variant[Integer[0], Enum['disabled', 'unlimited']],
      # Size limits and Paged Results
      Optional['size.pr']        => Variant[Integer[0], Enum['noEstimate', 'unlimited']],
      Optional['size.prtotal']   => Variant[Integer[0], Enum['disabled', 'unlimited']],
    },
  ],
]
