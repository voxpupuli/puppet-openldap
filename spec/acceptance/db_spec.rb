require 'spec_helper_acceptance'

describe 'openldap::server::database' do
  before :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=com':
        ensure => absent,
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  after :all do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { ['dc=foo,dc=com', 'dc=bar,dc=com']:
        ensure => absent,
      }
    EOS

    apply_manifest(pp, :expect_changes => true)
    apply_manifest(pp, :catch_changes => true)
  end

  context 'without parameters' do
    it 'creates a database' do
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=com': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'can connect with ldapsearch' do
      ldapsearch('-LLL -x -b dc=foo,dc=com') do |r|
        expect(r.stdout).to match(/dn: dc=foo,dc=com/)
      end
    end
  end

  context 'with a directory' do
    it 'creates a database' do
      tmpdir = default.tmpdir('openldap')
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=bar,dc=com':
        directory => '#{tmpdir}',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'can connect with ldapsearch' do
      ldapsearch('-LLL -x -b dc=foo,dc=com') do |r|
        expect(r.stdout).to match(/dn: dc=foo,dc=com/)
      end
    end
  end

end

