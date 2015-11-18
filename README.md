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
openldap::server::access { '0 on dc=example,dc=com':
  what   => 'attrs=userPassword,shadowLastChange',
  access => [
    'by dn="cn=admin,dc=example,dc=com" write',
    'by anonymous auth',
    'by self write',
    'by * none',
  ],
} ->

openldap::server::access { '1 on dc=example,dc=com' :
  what   => 'dn.base=""'
  access => [
    'by * read'
  ],
} ->

openldap::server::access { '2 on dc=example,dc=com' :
  islast => true,
  what   => '*'
  access => [
    'by dn="cn=admin,dc=example,dc=com" write',
    'by * read',
  ],
}

```

from the openldap [documentation](http://www.openldap.org/doc/admin24/slapdconf2.html)
> The frontend is a special database that is used to hold database-level 
options that should be applied to all the other databases. Subsequent database
definitions may also override some frontend settings.

So use the suffix 'frontend' for this special database


```puppet
openldap::server::access { '0 on frontend' :
  what   => '*',
  access => [
    'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
    'by * break',
  ],
}
```


####Note #1:
The chaining arrows `->` are importants if you want to order your entries.
Openldap put the entry as the last available position.
So if you got in your ldap:
```
 olcAccess: {0}to ...
 olcAccess: {1}to ...
 olcAccess: {2}to ...
```

  Even if you set the parameter `position => '4'`, the next entry will be set as

```
 olcAccess: {3}to ...
```

####Note #2:
  The parameter `islast` is used for purging remaining entries
  So if you got in your ldap:
```
 olcAccess: {0}to ...
 olcAccess: {1}to ...
 olcAccess: {2}to ...
 olcAccess: {3}to ...
```

And set `islast => true` in `position => 1`, entries 2 and 3 will get deleted.

####Call your acl from a hash:

```puppet
$acl_hash = {
  'acl 1' => {
    suffix   => 'dc=example,dc=com',
    position => '1',
    what     => 'attrs=userPassword,shadowLastChange',
    by       => 'dn="cn=admin,dc=example,dc=com"',
    access   => 'write',
  },
  'acl 2' => {
    suffix   => 'dc=example,dc=com',
    position => '2',
    what     => 'attrs=userPassword,shadowLastChange',
    by       => 'anonymous',
    access   => 'auth',
  },
  'acl 3' => {
    suffix   => 'dc=example,dc=com',
    position => '3',
    what     => 'attrs=userPassword,shadowLastChange',
    by       => 'self',
    access   => 'write',
  },
}

$acl_hash_keys = keys($acl_hash)
openldap::server::access_wrapper { $acl_hash_keys :
  hash => $acl_hash,
}
```

And with a little help of an inline\_template, you can auto-generate your list
of acl like so:

```puppet
$acl = {
  '1 to *' => [
    'by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage',
    'by dn.exact=cn=admin,dc=example,dc=com write',
    'by dn.exact=cn=replicator,dc=example,dc=com read',
    'by * break',
  ],
  'to attrs=userPassword,shadowLastChange' => [
    'by dn="cn=admin,dc=example,dc=com" write',
    'by self write',
    'by anonymous auth',
  ],
  '2 to *' => [
    'by self read',
  ],
}

$acl_hash_yaml = inline_template('<%=
  position = -1
  acl.map { |to,access|
    position = position + 1
    {
      "#{position} on dc=example,dc=com" => {
        "position" => position,
        "what"     => to[/.*to (.*),1],
        "access"   => access,
        "suffix"   => "dc=example,dc=com",
      }
    }
}.flatten.reduce({}, :update).to_yaml
%>')

$acl_hash = parseyaml($acl_hash_yaml)
$acl_hash_keys = keys($acl_hash)

openldap::server::access_wrapper { $acl_hash_keys :
  hash => $acl_hash,
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
