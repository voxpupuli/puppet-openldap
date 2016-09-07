require 'spec_helper_acceptance'

describe 'openldap::server' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'openldap::server': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.not_to be_listening }
    end

  end

  context 'when adding certificates' do
    it 'with cert, key and ca' do
      pp = <<-EOS
        class { 'openldap::server':
          ssl_key   => "/etc/ldap/ssl/${::fqdn}.key",
          ssl_cert  => "/etc/ldap/ssl/${::fqdn}.crt",
          ssl_ca    => '/etc/ldap/ssl/ca.pem',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.not_to be_listening }
    end

    it 'can connect with ldapsearch using StartTLS' do
      skip
      ldapsearch('-LLL -x -b dc=example,dc=com -ZZ') do |r|
        expect(r.stdout).to match(/dn: dc=example,dc=com/)
      end
    end
  end

  context 'when enabling ldaps' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'openldap::server':
          ldaps_ifs => ['/'],
          ssl_key   => "/etc/ldap/ssl/${::fqdn}.key",
          ssl_cert  => "/etc/ldap/ssl/${::fqdn}.crt",
          ssl_ca    => '/etc/ldap/ssl/ca.pem',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.to be_listening }
    end

    it 'can connect with ldapsearch using ldaps:///' do
      skip
      ldapsearch('-LLL -x -b dc=example,dc=com -H ldaps:///') do |r|
        expect(r.stdout).to match(/dn: dc=example,dc=com/)
      end
    end
  end

end
