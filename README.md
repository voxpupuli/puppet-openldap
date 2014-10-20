OpenLDAP
========

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/openldap.svg)](https://forge.puppetlabs.com/camptocamp/openldap)
[![Build Status](https://travis-ci.org/camptocamp/puppet-openldap.png?branch=master)](https://travis-ci.org/camptocamp/puppet-openldap)

Overview
--------

The openldap module allows you to easily manage OpenLDAP with Puppet.
By default it will use OLC (cn=config).

Features supported per provider
-------------------------------

Object      | olc (slapd.d) | augeas (slapd.conf)
------------|---------------|-----------
global_conf | Y             | N
database    | Y             | Y
module      | Y             | N
overlay     | Y             | N
access      | Y             | N
index       | Y             | N
schema      | N             | N

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
openldap::server::database { 'dc=foo,dc=example.com':
  ensure => present,
}
```

For a more customized configuration:

```puppet
class { 'openldap::server':
  ldaps_ifs => ['/'],
  ssl_cert  => '/etc/ldap/ssl/slapd.pem',
  ssl_key   => '/etc/ldap/ssl/slapd.key',
}
```

If you need multiple databases:

```puppet
class { 'openldap::server':
  databases => {
    'dc=foo,dc=example,dc=com' => {
      directory => '/var/lib/ldap/foo',
    },
    'dc=bar,dc=example,dc=com' => {
      directory => '/var/lib/ldap/bar',
    },
  },
}
```

To force using slapd.conf:

```puppet
class { 'openldap::server':
  provider => 'augeas',
}
```

###Configuring a database

```puppet
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=example,dc=com',
  rootpw    => openldap_password('mySuperSecretPassword'),
}
```

###Configuring modules

```puppet
openldap::server::module { 'memberof':
  ensure => present,
}
```

###Configuring overlays

```puppet
openldap::server::overlay { 'memberof on dc=example,dc=com':
  ensure => present,
}
```

###Configuring ACPs/ACLs

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

* [openldap::client](#class-openldapclient)
* [openldap::server](#class-openldapserver)

Resources:

* [openldap::server::access](#resource-openldapserveraccess)
* [openldap::server::database](#resource-openldapserverdatabase)
* [openldap::server::globalconf](#resource-openldapserverglobalconf)
* [openldap::server::module](#resource-openldapservermodule)
* [openldap::server::overlay](#resource-openldapserveroverlay)
* [openldap::server::schema](#resource-openldapserverschema)

Functions:

* [openldap\_password](#function-openldappassword)

###Class: openldap::client

####`package`
Name of the package to install. Defaults to `libldap-2.4-2` on Debian and `openldap` on RedHat.

####`file`
Name of the configuration file. Defaults to `/etc/ldap/ldap.conf` on Debian and `/etc/openldap/ldap.conf` on RedHat.

####`base`
Specifies the default base DN to use when performing ldap operations.

####`uri`
Specifies the URI(s) of an LDAP server(s) to which the LDAP library should connect.

####`tls_cacert`
Specifies the file that contains certificates for all of the Certificate
Authorities the client will recognize.

###Class: openldap::server

####`package`
Name of the package to install. Defaults to `slapd` on Debian and 'openldap-servers` on RedHat.

####`file`
Name of the `slapd.conf` file to use with augeas provider. Defaults to `/etc/ldap/slapd.conf` on Debian and `/etc/openldap/slapd.conf` on RedHat.

####`service`
Name of the service. Defaults to `slapd` on Debian and RedHat 6 ; and `ldap` on RedHat 5.

####`owner`
The uid of the database folder. Defaults to `openldap` on Debian and `ldap` on RedHat.

####`group`
The gid of the database folder. Defaults to `openldap` on Debian and `ldap` on RedHat.

####`enable`
Should the service be enabled during boot time ?

####`start`
Should the service be started by Puppet ?

####`provider`
The provider to use to manage configuration.
Can be `olc` to manage configuration via (cn=config) or `augeas` to use slapd.conf (not working yet).
Defaults to `olc`.

####`ssl_cert`
Specifies the file that contains the slapd server certificate.

####`ssl_key`
Specifies the file that contains the slapd server private key.

####`ssl_ca`
Specifies the file that contains certificates for all of the Certificate
Authorities that slapd will recognize.

####`databases`
A hash containing the databases to create. Default to a single database with `$::domain` as suffix and `/var/lib/ldap` as directory.

####`ldap_ifs`
Array of 'interface'/'interface:port' values to serve unsecured requests. Defaults to ['/'] which means all ifaces, port 389.
Set to an empty array to disable interface.

####`ldaps_ifs`
Array of 'interface'/'interface:port' values to serve secured requests. Defaults to ['/'] which means all ifaces, port 636.
Set to an empty array to disable interface.

####`ldapi_ifs`
Array of 'interface'/'interface:port' values to serve IPC requests. Defaults to ['/'].
Set to an empty array to disable interface.

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

###Resource: openldap::server::global_conf

###Resource: openldap::server::module

###Resource: openldap::server::overlay

###Resource: openldap::server::schema

###Function: openldap_password

Contributors
------------

 * Bill ONeill
 * Christian Kaenzig
 * Ilya Kulakov
 * Mathieu Parent
 * Mickaël Canévet
 * Raphaël Pinson
 * Ronny Srnka
