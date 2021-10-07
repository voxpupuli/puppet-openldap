# @summary A valid acl value for openldap::server::access_wrapper
type Openldap::Access_hash = Hash[
  Openldap::Access_title,
  Struct[{
    position => Optional[Variant[Integer,String[1]]],
    what     => Optional[String[1]],
    access   => Array[Openldap::Access_rule],
    suffix   => Optional[String[1]],
  }],
]
