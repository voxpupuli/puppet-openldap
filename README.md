OpenLDAP
========

[![Build Status](https://github.com/voxpupuli/puppet-openldap/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-openldap/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-openldap/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-openldap/actions/workflows/release.yml)
[![Puppet Forge Version](http://img.shields.io/puppetforge/v/puppet/openldap.svg)](https://forge.puppetlabs.com/puppet/openldap)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppet/openldap.svg)](https://forge.puppetlabs.com/puppet/openldap)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/puppet/openldap.svg)](https://forge.puppetlabs.com/puppet/openldap)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-openldap)
[![Apache v2 License](https://img.shields.io/github/license/voxpupuli/puppet-openldap.svg)](LICENSE)
[![Donated by Camptocamp](https://img.shields.io/badge/donated%20by-camptocamp-fb7047.svg)](#transfer-notice)

Overview
--------

The openldap module allows you to easily manage OpenLDAP with Puppet.
By default it will use OLC (cn=config).

Features supported
------------------

Object      | olc (slapd.d)
------------|--------------
global_conf | Y
database    | Y
module      | Y
overlay     | Y
access      | Y
index       | Y
schema      | Y

Usage
-----

### Configuring the client

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

### Configuring the server

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

Configuring a global parameter:

```puppet
openldap::server::globalconf { 'security':
  ensure => present,
  value  => 'tls=128',
}
```

Configuring multiple olc serverIDs for multiple master or mirror mode

```puppet
openldap::server::globalconf { 'ServerID':
  ensure  => present,
  value   => { 'ServerID' => [ '1 ldap://master1.example.com', '2 ldap://master2.example.com' ] }
}
```

Configuring security for global

```puppet
openldap::server::globalconf { 'Security':
  ensure  => present,
	value   => { 'Security' => [ 'simple_bind=128', 'ssf=128', 'tls=0' ] }
```

### Configuring a database

```puppet
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=example,dc=com',
  rootpw    => 'secret',
}
```

`rootpw` will be automatically converted to a SSHA hash with random salt.

Support SHA-2 password
```puppet
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=example,dc=com',
  rootpw    => '{SHA384}QZdaK3FnibbilSPbthnf3cO8lBWsRyM9i1MZTUFP21RdBSLSNFgYc2eFFzJG/amX',
}
```

### Configuring modules

```puppet
openldap::server::module { 'memberof':
  ensure => present,
}
```

### Configuring overlays

```puppet
openldap::server::overlay { 'memberof on dc=example,dc=com':
  ensure => present,
}
```

### Configuring ACPs/ACLs

[Documentation](http://www.openldap.org/devel/admin/slapdconf2.html) about olcAcces state the following spec:
> 5.2.5.2. olcAccess: to &lt;what&gt; \[ by &lt;who&gt; \[&lt;accesslevel&gt;\] \[&lt;control&gt;\] \]+

Define priority and suffix in the title:
```puppet
openldap::server::access { '0 on dc=example,dc=com':
  what     => 'attrs=userPassword,shadowLastChange',
  access   => [
    'by dn="cn=admin,dc=example,dc=com" write',
    'by anonymous auth',
    'by self write',
    'by * none',
  ],
}
```

from the openldap [documentation](http://www.openldap.org/doc/admin24/slapdconf2.html)
> The frontend is a special database that is used to hold database-level
options that should be applied to all the other databases. Subsequent database
definitions may also override some frontend settings.

So use the suffix 'cn=frontend' for this special database


```puppet
openldap::server::access { '0 on cn=frontend' :
  what   => '*',
  access => [
    'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
    'by * break',
  ],
}
```

#### Note:
For purging unmanaged entries, rely on the `resources` resource:

```
resources { 'openldap_access':
  purge => true,
}

openldap::server::access { '0 on dc=example,dc=com':
  what   => ...,
  access => [...],
}
openldap::server::access { '1 on dc=example,dc=com':
  what   => ...,
  access => [...],
}
```

#### Call your acl from a hash:
The class `openldap::server::access_wrapper` was designed to simplify creating ACL.
Each ACL is distinct hash in order to avoid collisions when multiple identical `what` are present (`to *` in this example).

```puppet
$example_acl = [
  {
    'to *' => [
      'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
      'by dn.exact=cn=admin,dc=example,dc=com write',
      'by dn.exact=cn=replicator,dc=example,dc=com read',
      'by * break',
    ],
  },
  {
    'to attrs=userPassword,shadowLastChange' => [
      'by dn="cn=admin,dc=example,dc=com" write',
      'by self write',
      'by anonymous auth',
    ],
  },
  {
    'to *' => [
      'by self read',
    ],
  },
]


openldap::server::access_wrapper { 'dc=example,dc=com' :
  acl => $example_acl,
}
```

### Configuring Schemas
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

### Configuring Rewrite-overlay
```puppet
openldap::server::database { 'relay':
  ensure  => present,
  backend => 'relay',
  suffix  => 'o=example',
  relay   => 'dc=example,dc=com',
}->

openldap::server::overlay { "rwm on relay":
  ensure  => present,
  suffix  => 'cn=config',
  overlay => 'rwm',
  options => {
    'olcRwmRewrite' => [
      'rwm-rewriteEngine "on"',
      'rwm-suffixmassage , "dc=example,dc=com"]',
  },
}
```

### Configuring Dbindex

```puppet
# Configuration suffix
Openldap::Server::Dbindex {
  suffix => 'dc=example,dc=com',
}

# The module only sets "objectClass eq" by default
openldap::server::dbindex {
  'cn':
    attribute => 'cn',
    indices   => 'eq,pres,sub';
  'uid':
    attribute => 'uid',
    indices   => 'eq,pres,sub';
  'uidNumber':
    attribute => 'uidNumber',
    indices   => 'eq,pres';
  'gidNumber':
    attribute => 'gidNumber',
    indices   => 'eq,pres';
  'member':
    attribute => 'member',
    indices   => 'eq,pres';
  'memberUid':
    attribute => 'memberUid',
    indices   => 'eq,pres';
}
```

## Transfer Notice

This plugin was originally authored by [Camptocamp](http://www.camptocamp.com).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Camptocamp.

Previously: https://github.com/camptocamp/puppet-openldap
