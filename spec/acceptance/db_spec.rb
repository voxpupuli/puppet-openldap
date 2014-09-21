require 'spec_helper_acceptance'

describe 'openldap::server::database' do

  it 'creates a database' do
    tmpdir = default.tmpdir('openldap')
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=com':
        directory => '#{tmpdir}',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  it 'can connect with ldapsearch' do
    pending 'Database need initialization?'
    ldapsearch('-LLL -x -b dc=foo,dc=com') do |r|
      expect(r.stdout).to match(/dn: dc=foo,dc=com/)
    end
  end

  it 'removes a database' do
    pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=com':
        ensure    => absent,
      }
    EOS

    apply_manifest(pp, :expect_changes => true)
    apply_manifest(pp, :catch_changes => true)
  end

end

