OpenLDAP
========

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/openldap.svg)](https://forge.puppetlabs.com/camptocamp/openldap)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/openldap.svg)](https://forge.puppetlabs.com/camptocamp/openldap)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-openldap/master.svg)](https://travis-ci.org/camptocamp/puppet-openldap)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/camptocamp/openldap.svg)](https://forge.puppetlabs.com/camptocamp/openldap)
[![Gemnasium](https://img.shields.io/gemnasium/camptocamp/puppet-openldap.svg)](https://gemnasium.com/camptocamp/puppet-openldap)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

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
schema      | Y             | N

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

Configuring a global parameter:

```puppet
openldap::server::globalconf { 'security':
  ensure => present,
  value  => 'tls=128',
}
```

###Configuring a database

```puppet
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=example,dc=com',
  rootpw    => 'secret',
}
```

`rootpw` will be automatically converted to a SSHA hash with random salt.

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

###Configuring Schemas
```puppet
openldap::server::schema { 'samba':
  ensure  => present,
  path    => '/etc/ldap/schema/samba.schema',
  require => Openldap::Server::Schema["inetorgperson"],
}

openldap::server::schema { 'nis':
  ensure  => present,
  path    => '/etc/ldap/schema/nis.ldif',
  require => Openldap::Server::Schema["inetorgperson"],
}
```
