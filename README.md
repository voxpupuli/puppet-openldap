OpenLDAP
========

[![Build Status](https://travis-ci.org/mcanevet/puppet-openldap.png?branch=master)](https://travis-ci.org/mcanevet/puppet-openldap)

Overview
--------

The openldap module allows you to easily manage OpenLDAP with Puppet.
By default it will use OLC (cn=config) on OpenLDAP 2.3+ and slapd.conf otherwise.

Usage
-----

###Configuring the client

```puppet
class { 'openldap::client': }
```

For a more customized configuration:

```puppet
class { 'openldap::client':
  base       => 'dc=example,dc=com',
  uri        => ['ldap://ldap.example.com', 'ldap://ldap-master.example.com:666'],
  tls_cacert => '/etc/ssl/certs/ca-certificates.crt',
}
```

###Configuring the server

```puppet
class { 'openldap::server': }
```

For a more customized configuration:

```puppet
class { 'openldap::server':
  ssl      => true,
  ssl_cert => '/etc/ldap/ssl/slapd.pem',
  ssl_key  => '/etc/ldap/ssl/slapd.key',
}
```

Configure the default database:

```puppet
class { 'openldap::server':
  databases => {
    'dc=example,dc=com' => {
      directory => '/var/lib/ldap',
    },
  },
}
```

If only one database is passed to `openldap::server` then it is used to during installation.

If you need multiple databases, you have to set the default one:

```puppet
class { 'openldap::server':
  databases        => {
    'dc=foo,dc=example,dc=com' => {
      directory => '/var/lib/ldap/foo',
    },
    'dc=bar,dc=example,dc=com' => {
      directory => '/var/lib/ldap/bar',
    },
  },
  default_database => 'dc=bar,dc=example,dc=com',
}
```

To force using slapd.conf on OpenLDAP 2.3+ (not working yet):

```puppet
class { 'openldap::server':
  provider => 'augeas',
}
```

###Configuring a database

```puppet
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootpw    => openldap_password('mySuperSecretPassword'),
}
```

###Configuring modules

```puppet
openldap::server::module { 'memberof':
  ensure => present,
}
```

###Configuring ACPs/ACLs (experimental)

```puppet
openldap::server::access {
  'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com':
    access => 'write';
  'to attrs=userPassword,shadowLastChange by anonymous on dc=example,dc=com':
    access => 'auth';
  'to attrs=userPassword,shadowLastChange by self on dc=example,dc=com':
    access => 'write';
  'to attrs=userPassword,shadowLastChange by * on dc=example,dc=com':
    access => 'none';
}

openldap::server::access { 'to dn.base="" by * on dc=example,dc=com':
  access => 'read',
}

openldap::server::access {
  'to * by dn="cn=admin,dc=example,dc=com" on dc=example,dc=com':
    access => 'write';
  'to * by * on dc=example,dc=com':
    access => 'read';
}
```

Reference
---------

Classes:

* [openldap](#class-openldap)
* [openldap::client](#class-openldapclient)
* [openldap::client::config](#class-openldapclientconfig)
* [openldap::client::install](#class-openldapclientinstall)
* [openldap::client::service](#class-openldapclientservice)
* [openldap::server](#class-openldapserver)
* [openldap::server::config](#class-openldapserverconfig)
* [openldap::server::install](#class-openldapserver::install)
* [openldap::server::service](#class-openldapserver::service)

Resources:

* [openldap_access](#resource-openldapaccess)
* [openldap_database](#resource-openldapdatabase)
* [openldap_global_conf](#resource-openldapglobalconf)
* [openldap::server::access](#resource-openldapserveraccess)
* [openldap::server::database](#resource-openldapserverdatabase)
* [openldap::server::globalconf](#resource-openldapserverglobalconf)

###Class: openldap

####`client`
Whether or not manage the OpenLDAP client.

####`server`
whether or not manage the OpenLDAP server.

###Class: openldap::client

####`package`
Name of the package to install. Defaults to `libldap-2.4-2` on Debian.

####`file`
Name of the configuration file. Defaults to `/etc/ldap/ldap.conf` on Debian.

####`base`
Specifies the default base DN to use when performing ldap operations.


####`uri`
Specifies the URI(s) of an LDAP server(s) to which the LDAP library should connect.

####`tls_cacert`
Specifies the file that contains certificates for all of the Certificate
Authorities the client will recognize.

###Class: openldap::server

####`package`
Name of the package to install. Defaults to `slapd` on Debian.

####`service`
Name of the service. Defaults to `slapd` on Debian.

####`enable`
Should the service be enabled during boot time?

####`start`
Should the service be started by Puppet

####`provider`
The provider to use to manage configuration.
Can be `olc` to manage configuration via (cn=config) or `augeas` to use slapd.conf.
Defaults to `olc` on OpenLDAP 2.3+ and augeas otherwise.

####`ssl`
Should OpenLDAP listen on SSL.

####`ssl_cert`
Specifies the file that contains the slapd server certificate.

####`ssl_key`
Specifies the file that contains the slapd server private key.

####`ssl_ca`
Specifies the file that contains certificates for all of the Certificate
Authorities that slapd will recognize.

###Resource: openldap::server::access

This resource allows you to manage OpenLDAP accesses to a database.

###`ensure`
Whether or not the resource should be present, or if its position should be forced.

Possible values are: `present`, `absent` and `positioned`.

###`position`
The position where the entry should be created. If omitted, it will be appended to the end of the file.

The position is of the form `<before|after> access to <what> by <whom>`, for example:

 - `before access to * by *`
 - `after access to dn="cn=admin,dc=nodomain" by self`

If `ensure` is set to `present`, the position will only be used when creating the entry.

If `ensure` is set to `positioned`, the entry will be destroyed and created again in the right position if it was not properly positioned. Beware of ordering between you resources!

###`what`
The entries and/or attributes to which the access applies.

###`by`
Which entities are granted access.

###`suffix`
On which database the access applies.

###`access`
The access rule.

###`control`
Controls the flow of access rule application.

###Resource: openldap::server::database

This resource allows you to manage OpenLDAP bdb and hdb databases.

####`suffix`
Specify the DN suffix of queries that will be passed to this backend database. This is the namevar.

####`index`
Index of the database to replace (otherwise create a new one if not exists).

####`backend`
Backend of the database. Must be one of `bdb` or `hdb`.

####`directory`
Specify the directory where the BDB files containing this database and
associated indexes live. A separate directory must be specified for each
database. The default is `/var/lib/ldap`.

####`rootdn`
Specify the distinguished name that is not subject to access control or
administrative limit restrictions for operations on this database.

####`rootpw`
Specify a password (or hash of the password) for the rootdn.

