require 'spec_helper_acceptance'

describe 'openldap::server' do

  it "with ldap_ifs => ['/']" do
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

  it 'can connect with ldapsearch using StartTLS' do
    pending
    ldapsearch('-LLL -x -b dc=example,dc=com') do |r|
      expect(r.stdout).to match(/dn: dc=example,dc=com/)
    end
  end

end
