# A set of LDAP attributes
type Openldap::Attributes = Variant[
  Hash[
    String[1],
    Variant[
      String[1],
      Array[
        String[1],
        1,
      ],
    ],
  ],
  Array[
    Openldap::Attribute,
    1,
  ],
  Openldap::Attribute,
]
