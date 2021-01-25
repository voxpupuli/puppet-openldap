# The list of possible values TLS_MOZNSS_COMPATIBILITY can have (based on the man page), and an 'absent' (a puppet directive to remove an existing declaration).
type Openldap::Tls_moznss_compatibility = Enum['on', 'true', 'yes', 'off', 'false', 'no', 'absent']  # lint:ignore:quoted_booleans
