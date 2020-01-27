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

      idempotent_apply(pp)
    end
  end

  context 'adds custom schema' do
    it 'adds puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet1.schema'))
      schema = File.read(fixture)
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.schema':
        ensure => 'present',
        content => @(EOIS)
#{schema}
        |EOIS
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.schema',
      }
      EOS

      idempotent_apply(pp)
    end
  end

  context 'modifies custom schema' do
    it 'modifies puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet2.schema'))
      schema = File.read(fixture)
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.schema':
        ensure  => 'present',
        content => @(EOIS)
#{schema}
        |EOIS
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.schema',
      }
      EOS

      idempotent_apply(pp)
    end
  end

  context 'remove custom schema' do
    it 'cleans up custom schema' do
      run_shell('service slapd stop')
      if os[:family] == 'Debian'
        run_shell('rm -f /etc/ldap/slapd.d/cn=config/cn=schema/*puppet.ldif')
      else
        run_shell('rm -f /etc/openldap/slapd.d/cn=config/cn=schema/*puppet.ldif')
      end
      run_shell('service slapd start')
    end
  end

  context 'adds custom ldif schema' do
    it 'adds puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet1.ldif'))
      schema = File.read(fixture)
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.ldif':
        ensure => 'present',
        content => @(EOIS)
#{schema}
        |EOIS
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.ldif',
      }
      EOS

      idempotent_apply(pp)
    end
  end

  context 'modifies custom ldif schema' do
    it 'modifies puppet schema' do
      fixture = File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/schema/puppet2.ldif'))
      schema = File.read(fixture)
      pp = <<-EOS
      class { 'openldap::server': }
      file { '/tmp/puppet.ldif':
        ensure => 'present',
        content => @(EOIS)
#{schema}
        |EOIS
      }
      -> openldap::server::schema { 'puppet':
        ensure => present,
        path   => '/tmp/puppet.ldif',
      }
      EOS

      idempotent_apply(pp)
    end
  end
end
