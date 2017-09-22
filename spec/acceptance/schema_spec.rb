require 'spec_helper_acceptance'

describe 'openldap::server::schema' do

  context 'without parameters' do
    it 'creates an overlay' do
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::schema { 'misc':
        ensure => present,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'adds custom schema' do
    it 'adds puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet1.schema'))
      scp_to(hosts, fixture, '/tmp/puppet1.schema')
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.schema':
        ensure => 'present',
        source => '/tmp/puppet1.schema',
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.schema',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'modifies custom schema' do
    it 'modifies puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet2.schema'))
      scp_to(hosts, fixture, '/tmp/puppet2.schema')
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.schema':
        ensure => 'present',
        source => '/tmp/puppet2.schema',
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.schema',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'remove custom schema' do
    it 'cleans up custom schema' do
      on hosts, 'service slapd stop'
      if fact(:osfamily) == 'Debian'
        on hosts, 'rm -f /etc/ldap/slapd.d/cn=config/cn=schema/*puppet.ldif'
      else
        on hosts, 'rm -f /etc/openldap/slapd.d/cn=config/cn=schema/*puppet.ldif'
      end
      on hosts, 'service slapd start'
    end
  end

  context 'adds custom ldif schema' do
    it 'adds puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet1.ldif'))
      scp_to(hosts, fixture, '/tmp/puppet1.ldif')
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.ldif':
        ensure => 'present',
        source => '/tmp/puppet1.ldif',
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.ldif',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'modifies custom ldif schema' do
    it 'modifies puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet2.ldif'))
      scp_to(hosts, fixture, '/tmp/puppet2.ldif')
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.ldif':
        ensure => 'present',
        source => '/tmp/puppet2.ldif',
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.ldif',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end


