OpenLDAP
========

Overview
--------

The openldap module allows you to easily manage OpenLDAP with Puppet.

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
  uri        => 'ldap://ldap.example.com ldap://ldap-master.example.com:666',
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

* [openldap_global_conf](#resource-openldapglobalconf)

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

####`ssl`
Should OpenLDAP listen on SSL.

####`ssl_cert`
Specifies the file that contains the slapd server certificate.

####`ssl_key`
Specifies the file that contains the slapd server private key.

####`ssl_ca`
Specifies the file that contains certificates for all of the Certificate
Authorities that slapd will recognize.
