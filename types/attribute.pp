# An LDAP attribute in the form "key: value"
type Openldap::Attribute = Pattern[/\A[^ ]+: [^\n]+/]
