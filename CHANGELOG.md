# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v7.0.0](https://github.com/voxpupuli/puppet-openldap/tree/v7.0.0) (2023-06-28)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v6.1.0...v7.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#379](https://github.com/voxpupuli/puppet-openldap/pull/379) ([bastelfreak](https://github.com/bastelfreak))
- Grant access to the specified RootDN if one is given [\#362](https://github.com/voxpupuli/puppet-openldap/pull/362) ([VictorPavlushin](https://github.com/VictorPavlushin))

**Implemented enhancements:**

- Improve service bootstraping on Debian [\#387](https://github.com/voxpupuli/puppet-openldap/pull/387) ([smortex](https://github.com/smortex))
- Relax dependencies version requirements [\#385](https://github.com/voxpupuli/puppet-openldap/pull/385) ([smortex](https://github.com/smortex))
- Allow management of the package versions installed [\#384](https://github.com/voxpupuli/puppet-openldap/pull/384) ([gcoxmoz](https://github.com/gcoxmoz))
- Add olcMultiProvider as a database config parameter [\#383](https://github.com/voxpupuli/puppet-openldap/pull/383) ([gcoxmoz](https://github.com/gcoxmoz))
- Add support for Puppet 8 [\#381](https://github.com/voxpupuli/puppet-openldap/pull/381) ([smortex](https://github.com/smortex))

**Closed issues:**

- Version 6.1.0 breaks disabling nonexistent services [\#386](https://github.com/voxpupuli/puppet-openldap/issues/386)

**Merged pull requests:**

- Remove unage of legacy stdlib function [\#380](https://github.com/voxpupuli/puppet-openldap/pull/380) ([smortex](https://github.com/smortex))

## [v6.1.0](https://github.com/voxpupuli/puppet-openldap/tree/v6.1.0) (2023-04-13)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v6.0.1...v6.1.0)

**Implemented enhancements:**

- Support Ubuntu 22.04 [\#376](https://github.com/voxpupuli/puppet-openldap/pull/376) ([chrisongthb](https://github.com/chrisongthb))
- Add EL9 support [\#375](https://github.com/voxpupuli/puppet-openldap/pull/375) ([treydock](https://github.com/treydock))
- Add EL8 support [\#373](https://github.com/voxpupuli/puppet-openldap/pull/373) ([treydock](https://github.com/treydock))
- Allow to configure more overlays [\#370](https://github.com/voxpupuli/puppet-openldap/pull/370) ([smortex](https://github.com/smortex))

**Closed issues:**

- dc=my-domain,dc=com entry in Database [\#366](https://github.com/voxpupuli/puppet-openldap/issues/366)

**Merged pull requests:**

- Rework default database lifecycle on Debian [\#372](https://github.com/voxpupuli/puppet-openldap/pull/372) ([smortex](https://github.com/smortex))
- Update tests to remove skips [\#371](https://github.com/voxpupuli/puppet-openldap/pull/371) ([smortex](https://github.com/smortex))

## [v6.0.1](https://github.com/voxpupuli/puppet-openldap/tree/v6.0.1) (2023-03-01)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v6.0.0...v6.0.1)

**Fixed bugs:**

- Rename former herculesteam dependencies to reflect transfer to Vox [\#367](https://github.com/voxpupuli/puppet-openldap/pull/367) ([gcoxmoz](https://github.com/gcoxmoz))

**Merged pull requests:**

- Document `openldap::server::dbindex` in the README [\#365](https://github.com/voxpupuli/puppet-openldap/pull/365) ([phaedriel](https://github.com/phaedriel))
- Remove legacy facts from hiera configuration [\#364](https://github.com/voxpupuli/puppet-openldap/pull/364) ([smortex](https://github.com/smortex))

## [v6.0.0](https://github.com/voxpupuli/puppet-openldap/tree/v6.0.0) (2022-11-22)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v5.0.1...v6.0.0)

**Breaking changes:**

- Update FreeBSD default version for OpenLDAP [\#356](https://github.com/voxpupuli/puppet-openldap/pull/356) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add Support for lastbind  [\#355](https://github.com/voxpupuli/puppet-openldap/pull/355) ([section1](https://github.com/section1))

**Fixed bugs:**

- replica chaining to support ldap backend suffix [\#354](https://github.com/voxpupuli/puppet-openldap/pull/354) ([gotvach](https://github.com/gotvach))
- Return integers for openldap\_database olcSecurity [\#353](https://github.com/voxpupuli/puppet-openldap/pull/353) ([gcoxmoz](https://github.com/gcoxmoz))

**Closed issues:**

- Data type enforcement for openldap\_database security is not idempotent [\#360](https://github.com/voxpupuli/puppet-openldap/issues/360)

## [v5.0.1](https://github.com/voxpupuli/puppet-openldap/tree/v5.0.1) (2022-02-02)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v5.0.0...v5.0.1)

**Fixed bugs:**

- Fix `$openldap::server::database::dboptions` data type [\#350](https://github.com/voxpupuli/puppet-openldap/pull/350) ([smortex](https://github.com/smortex))

## [v5.0.0](https://github.com/voxpupuli/puppet-openldap/tree/v5.0.0) (2022-01-25)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v4.0.0...v5.0.0)

**Breaking changes:**

- Drop support for FreeBSD 11 \(EOL\) [\#331](https://github.com/voxpupuli/puppet-openldap/pull/331) ([smortex](https://github.com/smortex))
- Be more strict with access resource titles / ACL syntax [\#324](https://github.com/voxpupuli/puppet-openldap/pull/324) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Fix `$openldap::server::database::dboptions` data type [\#348](https://github.com/voxpupuli/puppet-openldap/pull/348) ([smortex](https://github.com/smortex))
- Fix `$openldap::server::database::security` data type [\#347](https://github.com/voxpupuli/puppet-openldap/pull/347) ([smortex](https://github.com/smortex))
- Fix `$openldap::server::database::limits` data type [\#346](https://github.com/voxpupuli/puppet-openldap/pull/346) ([Donatien26](https://github.com/Donatien26))
- Fix FreeBSD default database directory [\#342](https://github.com/voxpupuli/puppet-openldap/pull/342) ([smortex](https://github.com/smortex))
- Fix FreeBSD slapd.d bootstrapping [\#341](https://github.com/voxpupuli/puppet-openldap/pull/341) ([smortex](https://github.com/smortex))
- Fix FreeBSD default value for ldapi\_ifs [\#340](https://github.com/voxpupuli/puppet-openldap/pull/340) ([smortex](https://github.com/smortex))
- Fix provider for `cn=config` bootstrap on FreeBSD [\#339](https://github.com/voxpupuli/puppet-openldap/pull/339) ([smortex](https://github.com/smortex))
- Fix `$openldap::server::database::mirrormode` data type [\#335](https://github.com/voxpupuli/puppet-openldap/pull/335) ([smortex](https://github.com/smortex))

**Closed issues:**

- Wrong data type for `$openldap::server::database::limits` [\#345](https://github.com/voxpupuli/puppet-openldap/issues/345)
- Unable to configure openldap on FreeBSD 13.0-RELEASE [\#338](https://github.com/voxpupuli/puppet-openldap/issues/338)
- `$openldap::server::database::mirrormode` does not enable olcMirrorMode [\#333](https://github.com/voxpupuli/puppet-openldap/issues/333)
- `undefined method 'flatten' for nil:NilClass` in openldap\_access provider [\#294](https://github.com/voxpupuli/puppet-openldap/issues/294)
- Documentation for frontend acl is incorrect [\#282](https://github.com/voxpupuli/puppet-openldap/issues/282)

**Merged pull requests:**

- Fix suffix of frontend database in README [\#336](https://github.com/voxpupuli/puppet-openldap/pull/336) ([smortex](https://github.com/smortex))
- Simplify some code duplication [\#332](https://github.com/voxpupuli/puppet-openldap/pull/332) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/voxpupuli/puppet-openldap/tree/v4.0.0) (2021-09-27)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v3.1.0...v4.0.0)

**Breaking changes:**

- Drop support for openldap\_access' islast parameter [\#327](https://github.com/voxpupuli/puppet-openldap/pull/327) ([smortex](https://github.com/smortex))
- Drop support of Debian 8, 9 and Ubuntu 16.04 \(EOL\) [\#313](https://github.com/voxpupuli/puppet-openldap/pull/313) ([smortex](https://github.com/smortex))
- Acceptance tests for CentOS 7 , remove RHEL6 [\#309](https://github.com/voxpupuli/puppet-openldap/pull/309) ([treydock](https://github.com/treydock))

**Implemented enhancements:**

- Include missing class instead of raising an error [\#322](https://github.com/voxpupuli/puppet-openldap/pull/322) ([smortex](https://github.com/smortex))
- Update FreeBSD package names [\#321](https://github.com/voxpupuli/puppet-openldap/pull/321) ([smortex](https://github.com/smortex))
- Add support for Debian 11 [\#314](https://github.com/voxpupuli/puppet-openldap/pull/314) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Fix $openldap::server::database data type [\#329](https://github.com/voxpupuli/puppet-openldap/pull/329) ([smortex](https://github.com/smortex))
- Fix openldap\_access's what parameter [\#326](https://github.com/voxpupuli/puppet-openldap/pull/326) ([smortex](https://github.com/smortex))
- Fix data type for openldap::server::overlay::options [\#320](https://github.com/voxpupuli/puppet-openldap/pull/320) ([smortex](https://github.com/smortex))
- Fix data type for $openldap::server::globalconf::value [\#318](https://github.com/voxpupuli/puppet-openldap/pull/318) ([smortex](https://github.com/smortex))
- Fix purging puppet resource openldap\_access [\#315](https://github.com/voxpupuli/puppet-openldap/pull/315) ([smortex](https://github.com/smortex))
- Fix type of $openldap::server::access\_wrapper::acl [\#312](https://github.com/voxpupuli/puppet-openldap/pull/312) ([smortex](https://github.com/smortex))

**Closed issues:**

- openldap::server::database initdb data type should support value false [\#328](https://github.com/voxpupuli/puppet-openldap/issues/328)
- openldap::server::overlay does not allow tuples as options [\#319](https://github.com/voxpupuli/puppet-openldap/issues/319)
- Regression in treatment of Globalconf [\#317](https://github.com/voxpupuli/puppet-openldap/issues/317)
- Purging openldap\_access is highly unreliable. [\#280](https://github.com/voxpupuli/puppet-openldap/issues/280)

## [v3.1.0](https://github.com/voxpupuli/puppet-openldap/tree/v3.1.0) (2021-08-28)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Improve initdb for openldap\_database type [\#209](https://github.com/voxpupuli/puppet-openldap/pull/209) ([treydock](https://github.com/treydock))

**Fixed bugs:**

- Delete database dc=my-domain,dc=com on RedHat systems [\#211](https://github.com/voxpupuli/puppet-openldap/pull/211) ([treydock](https://github.com/treydock))

**Closed issues:**

- Modernizing the module [\#270](https://github.com/voxpupuli/puppet-openldap/issues/270)

**Merged pull requests:**

- Allow up-to-date dependencies [\#310](https://github.com/voxpupuli/puppet-openldap/pull/310) ([smortex](https://github.com/smortex))

## [v3.0.0](https://github.com/voxpupuli/puppet-openldap/tree/v3.0.0) (2021-08-11)

[Full Changelog](https://github.com/voxpupuli/puppet-openldap/compare/2.0.0...v3.0.0)

**Breaking changes:**

- Drop support for Ubuntu 14.04 [\#304](https://github.com/voxpupuli/puppet-openldap/pull/304) ([smortex](https://github.com/smortex))
- Drop support for the augeas provider [\#291](https://github.com/voxpupuli/puppet-openldap/pull/291) ([raphink](https://github.com/raphink))

**Implemented enhancements:**

- Add support for Ubuntu 20.04 [\#303](https://github.com/voxpupuli/puppet-openldap/pull/303) ([smortex](https://github.com/smortex))
- Add support for Debian 10 [\#302](https://github.com/voxpupuli/puppet-openldap/pull/302) ([smortex](https://github.com/smortex))
- Add support for FreeBSD 13 [\#301](https://github.com/voxpupuli/puppet-openldap/pull/301) ([smortex](https://github.com/smortex))
- Add data types for all parameters [\#300](https://github.com/voxpupuli/puppet-openldap/pull/300) ([smortex](https://github.com/smortex))
- Remove slapd\_sockets shellvar when empty [\#299](https://github.com/voxpupuli/puppet-openldap/pull/299) ([smortex](https://github.com/smortex))
- Switch to regular OpenLDAP packages on FreeBSD [\#296](https://github.com/voxpupuli/puppet-openldap/pull/296) ([smortex](https://github.com/smortex))
- Move from params.pp to Hiera data [\#287](https://github.com/voxpupuli/puppet-openldap/pull/287) ([smortex](https://github.com/smortex))
- Bootstrap cn=config database on FreeBSD [\#278](https://github.com/voxpupuli/puppet-openldap/pull/278) ([HerveMARTIN](https://github.com/HerveMARTIN))
- Add support for Suse and SLES [\#275](https://github.com/voxpupuli/puppet-openldap/pull/275) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- Remove dead code [\#269](https://github.com/voxpupuli/puppet-openldap/pull/269) ([smortex](https://github.com/smortex))
- Add support for FreeBSD [\#267](https://github.com/voxpupuli/puppet-openldap/pull/267) ([smortex](https://github.com/smortex))
- Catch olcAccess regex parse failures [\#264](https://github.com/voxpupuli/puppet-openldap/pull/264) ([spakka](https://github.com/spakka))

**Fixed bugs:**

- Fix starting LDAP on Suse [\#298](https://github.com/voxpupuli/puppet-openldap/pull/298) ([smortex](https://github.com/smortex))
- Fix warning about malformed YAML file [\#285](https://github.com/voxpupuli/puppet-openldap/pull/285) ([smortex](https://github.com/smortex))
- Unbreak with Puppet 7.4.0 / 6.21.0 on Debian 10 [\#284](https://github.com/voxpupuli/puppet-openldap/pull/284) ([smortex](https://github.com/smortex))

**Closed issues:**

- Warning on startup on FreeBSD with slapd\_sockets shellvar [\#277](https://github.com/voxpupuli/puppet-openldap/issues/277)
- Multiple providers alerts [\#156](https://github.com/voxpupuli/puppet-openldap/issues/156)

**Merged pull requests:**

- Update badges in README.md [\#308](https://github.com/voxpupuli/puppet-openldap/pull/308) ([root-expert](https://github.com/root-expert))
- puppetlabs/stdlib: allow 7.x [\#305](https://github.com/voxpupuli/puppet-openldap/pull/305) ([smortex](https://github.com/smortex))
- Add management of TLS\_MOZNSS\_COMPATIBILITY to ldap.conf [\#272](https://github.com/voxpupuli/puppet-openldap/pull/272) ([gcoxmoz](https://github.com/gcoxmoz))

## [2.0.0](https://github.com/voxpupuli/puppet-openldap/tree/2.0.0) (2020-03-02)

- update dependencies and Puppet version [\#261](https://github.com/camptocamp/puppet-openldap/pull/261) ([Dan33l](https://github.com/Dan33l))
- declare this module as compatible with ubuntu1804 [\#260](https://github.com/camptocamp/puppet-openldap/pull/260) ([Dan33l](https://github.com/Dan33l))
- Port openldap\_password() to Puppet 4.x function API [\#258](https://github.com/camptocamp/puppet-openldap/pull/258) ([raphink](https://github.com/raphink))

## 2020-01-28 - Release 1.18.0

- Fix acceptance [\#257](https://github.com/camptocamp/puppet-openldap/pull/257) ([raphink](https://github.com/raphink))
- Convert to PDK [\#254](https://github.com/camptocamp/puppet-openldap/pull/254) ([raphink](https://github.com/raphink))
- add parameter nss\_initgroups\_ignoreusers [\#253](https://github.com/camptocamp/puppet-openldap/pull/253) ([tobiWu](https://github.com/tobiWu))
- Mark test as pending [\#252](https://github.com/camptocamp/puppet-openldap/pull/252) ([mcanevet](https://github.com/mcanevet))
- Fix title\_patterns to support multiple fields in what [\#250](https://github.com/camptocamp/puppet-openldap/pull/250) ([raphink](https://github.com/raphink))
- add sssvlv overlay compatibility [\#247](https://github.com/camptocamp/puppet-openldap/pull/247) ([clement-dufaure](https://github.com/clement-dufaure))
- Add support for back\_ldap and specific values of attrs in ACLs [\#246](https://github.com/camptocamp/puppet-openldap/pull/246) ([jdow](https://github.com/jdow))
- Fix regexp in access\_wrapper [\#243](https://github.com/camptocamp/puppet-openldap/pull/243) ([amateo](https://github.com/amateo))
- Enable usage of puppetlabs-stdlib 5.x.x [\#240](https://github.com/camptocamp/puppet-openldap/pull/240) ([jacksgt](https://github.com/jacksgt))
- Fix regex for group-based limits [\#235](https://github.com/camptocamp/puppet-openldap/pull/235) ([kasimon](https://github.com/kasimon))
- Add socks support [\#233](https://github.com/camptocamp/puppet-openldap/pull/233) ([jas01](https://github.com/jas01))
- Fix usage of slapcat when removing an overlay [\#232](https://github.com/camptocamp/puppet-openldap/pull/232) ([treydock](https://github.com/treydock))
- Fix setting ACL if they had been set before [\#230](https://github.com/camptocamp/puppet-openldap/pull/230) ([fklajn-opera](https://github.com/fklajn-opera))
- cn can be in uppercase [\#190](https://github.com/camptocamp/puppet-openldap/pull/190) ([Poil](https://github.com/Poil))
- Add support for back\_sock [\#173](https://github.com/camptocamp/puppet-openldap/pull/173) ([jas01](https://github.com/jas01))
- Support SASL and GSSAPI options in ldap.conf [\#165](https://github.com/camptocamp/puppet-openldap/pull/165) ([modax](https://github.com/modax))

## 2018-09-07 - Release 1.17.0

- Drop legacy PE statement and puppet_version in metadata.json
- Bump to minimal recommended Puppet version
- Bump stdlib to 4.13.1 to get data types
- Replace validate\_\* calls with datatypes
- Drop legacy tests
- Add Archlinux support (GH #187)
- Ensure that the password is hashed on db creation
- Set sensible default for dbindex attribute
- Rewrite openldap\_password to use native Ruby
- Fix title patterns to no longer use unsupported proc (GH #222)
- Remove Debian 6 support and add Debian 9
- Fix openldap\_overlap to perform add operation when adding new options
- Support schema update via OLC
- Add support to modify openldap\_schema resources

## 2017-06-06 - Release 1.16.1

- Fix metadata.json

## 2017-06-06 - Release 1.16.0

- Fixed bug for spaces in the "by" section of the rule
- Allow to set rewrite overlay with a relay database
- Fixes errata - puppet creates a rwm overlay every runs
- Any prefixed numbers should be absent in the options
- Refactor openldap::server::access
- Add security attribute to database resource
- Syncrepl now run idempotently
- Use ldapmodify function instead of the slapdd which is not defined
- Support Amazon linux 2015+ and make version checks more flexible
- Mod global conf
- Fix variables out of scope
- Make NETWORK_TIMEOUT a configurable option
- Use contain instead of include
- Fix ordering so that Openldap::Server::Globalconf resources will come after the openldap service
- Change updateref order to avoid error '<olcUpdateRef> must appear after syncrepl or updatedn
- Adding dbmaxsize parameter for big dbs
- Remove requirements from metadata.json
- Supports SHA2 password
- Allow openldap::client config values to have 'absent' value remove the entry from ldap.conf
- openldap_database: Default to mdb for new Ubuntus

## 2016-08-22 - Release 1.15.0

- Add base provider that implements common commands and methods and use it
- Fixed an idempotency issue on the syncrepl variable
- Fix idempotency issue when ensuring absent of multiple databases

## 2016-02-18 - Release 1.14.0

- Add support for the rwm overlay (issue #117)
- Manage line breaks in overlay config and add smbk5pwd overlay support (issue #122)
- Avoid duplicate declaration of openldap-clients package (issue #123)
- Allow dn, filter and attrs to be defined concurrently (issue #124)

## 2016-01-11 - Release 1.13.0

- Fix for frontend and config databases
- Add serveral params for ldap.conf to openldap::client.
- Add timeout and timelimit options
- Add sudo options
- Add binddn and bindpw options to ldap client

## 2015-11-18 - Release 1.12.0

- Add objectClass for the unique overlay
- Support for adding access based on olcDatabase
- Fix prefetch with composite namevars
- Use puppet4 for acceptance tests

## 2015-11-09 - Release 1.11.0

- Do not try to hash password if it is given in "{SSHA}" form
- Add cn=config suffix support
- Add readonly support to openldap_database's augeas provider

## 2015-10-09 - Release 1.10.0

- Fix ACL changes
- Fix syncprov overlay
- Add support for refint overlay

## 2015-08-21 - Release 1.9.2

- Use docker for acceptance tests

## 2015-07-08 - Release 1.9.1

- Fix TLS setting on new versions of OpenLDAP

## 2015-07-08 - Release 1.9.0

- Add more parameters to openldap::server::database
- Add support for accesslog overlay

## 2015-06-26 - Release 1.8.2

- Fix strict_variables activation with rspec-puppet 2.2

## 2015-06-24 - Release 1.8.1

- Add missing 'ensure' parameter to 'openldap::server::globalconf'

## 2015-06-19 - Release 1.8.0

- Revert "Use ruby to generate idempotent SSHA password (more secure password)
- Add support to configure overlays on a database
- Fix some issues on Ubuntu (no official support yet)
- Update documentation
- Don't convert schema if already in LDIF format

## 2015-06-19 - Release 1.7.0

- Add `initdb` param to `openldap::server::database` define to allow to not
  initialize database.

## 2015-05-28 - Release 1.6.5

- Add beaker_spec_helper to Gemfile

## 2015-05-26 - Release 1.6.4

- Use random application order in nodeset

## 2015-05-26 - Release 1.6.3

- add utopic & vivid nodesets

## 2015-05-25 - Release 1.6.2

- Don't allow failure on Puppet 4

## 2015-05-13 - Release 1.6.1

- Add puppet-lint-file_source_rights-check gem

## 2015-05-13 - Release 1.6.0

- Add support for schema

## 2015-05-12 - Release 1.5.5

- Don't pin beaker

## 2015-05-12 - Release 1.5.4

- Add documentation for puppet::server::globalconf
- Fix Beaker on Docker

## 2015-04-29 - Release 1.5.3

- Avoid logging password

## 2015-04-21 - Release 1.5.2

- Correct client package name for RHEL

## 2015-04-17 - Release 1.5.1

- Add beaker nodesets

## 2015-04-08 - Release 1.5.0

- Generate random salt for rootpw instead of using fqdn
- Deprecates openldap_password function
- Fix database destroy

## 2015-04-03 - Release 1.4.1

- Fix acceptance tests

## 2015-03-29 - Release 1.4.0

- Add more acceptance tests to travis matrix
- Confine pinning to rspec 3.1 to ruby 1.8
- openldap_password does not use slappasswd anymore
- openldap_password is idempotent
- Add MDB backend support
- Remove RedHat 5 support (may still work but not tested on travis)
- Add RedHat 7 support
- Add Debian 8 support
- Database creation don't require nis schema anymore
- Fix openldap_module on RedHat
- Set selinux to permissive on acceptance tests

## 2015-03-24 - Release 1.3.2

- Various spec improvements
- Fix specs

## 2015-03-06 - Release 1.3.1

- Destroy default database before creating new ones

## 2015-02-18 - Release 1.3.0

- Use params pattern
- Some minor fixes

## 2015-01-07 - Release 1.2.3

- Fix unquoted strings in cases

## 2015-01-05 - Release 1.2.2

- Fix .travis.yml

## 2014-12-18 - Release 1.2.1

- Various improvements in unit tests

## 2014-12-09 Release 1.2.0

- Fix metadata.json
- Add future parser tests
- Fix code for future parser
- Migrate tests to rspec 3 syntax
- Use puppet_facts in specs

## 2014-11-17 Release 1.1.4

- Fix acceptance tests

## 2014-11-13 Release 1.1.3

- Fix README
- Use Travis DPL for automatic releases
- Deprecate 2.7 support and add 3.7 support
- Lint metadata.json

## 2014-10-20 Release 1.1.2

- Really setup automatic forge releases

## 2014-10-20 Release 1.1.0

- Setup automatic forge releases

## 2014-10-07 Release 1.0.0

- Change usage : one must explicitely configure an openldap::server::database resource

## 2014-10-05 Release 0.5.3

- Fix service startup on RedHat

## 2014-09-23 Release 0.5.2

- Updated dependencies for augeasproviders
- Acceptance tests refactoring

## 2014-09-05 Release 0.5.1

- Fix for ruby 1.8.7
- Fix overlay
- Use .puppet-lin.rc
- Update travis matrix

## 2014-08-26 Release 0.5.0

- User augeasproviders 2.0.0 and re-enable augeas provider.

## 2014-07-02 Release 0.4.0

- This release add ability to specify ldap* interfaces and thus removes openldap::server::ssl parameter. It also add a new type/provider/define to manage dbindex.


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
