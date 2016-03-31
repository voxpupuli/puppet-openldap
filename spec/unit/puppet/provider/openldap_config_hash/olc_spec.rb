require 'spec_helper'

describe Puppet::Type.type(:openldap_config_hash).provider(:olc) do

  let(:params) do
    {
      # openldap::server::config_hash { 'TLSCertificate':
      #    value => {
      #      'TLSCertificateFile'    => $::openldap::server::ssl_cert,
      #      'TLSCertificateKeyFile' => $::openldap::server::ssl_key,
      #    },
      #  }
      :title    => 'TLSCertificate',
      :value    => {
	:TLSCertificateFile    => '/etc/ssl/certs/cert.pem',
        :TLSCertificateKeyFile => '/etc/ssl/private/key.pem',
        :LogLevel              => 'stats'
      }
    }
  end

  let(:slapcat_output_exists) do
    <<-LDIF
dn: cn=config
olcTLSCertificateFile: /etc/ssl/certs/cert.pam
olcTLSCertificateKeyFile: /etc/ssl/private/key.pam
LDIF
  end

  let(:create_ldif_ruby_1_8_7) do
    <<-LDIF
dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/key.pem
-
add: olcLogLevel
olcLogLevel: stats
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/cert.pem
-
LDIF
  end

  let(:create_ldif) do
    <<-LDIF
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/cert.pem
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/key.pem
-
add: olcLogLevel
olcLogLevel: stats
-
LDIF
  end

  let(:resource) do
    Puppet::Type.type(:openldap_config_hash).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:instance) { provider.class.instances.first }

  before do
  end

  describe 'self.instances' do
    it 'returns an array of cn=config entry resources' do
      r = provider.class.
        stubs(:slapcat).
        with('(objectClass=olcGlobal)').
        returns(slapcat_output_exists)

      instances = provider.class.instances

      expect(instances.class).to match(Array)
    end
  end

  describe 'when creating' do
    it 'should create an entry in cn=config' do
      provider.stubs(:ldapmodify).returns(0)

      # NOTE: Skiping this test in Ruby 1.8.x. The order of hash keys is not
      # defined and cannot be relied upon.
      # (http://stackoverflow.com/questions/19092185/ruby-hash-by-default-get-sorted-in-ruby-1-8-7)
      # By checking the created LDIF, the test relies on the order of hash keys
      # as is in the data passed to Puppet. So there's a 50:50 chance for the
      # test to fail on Ruby 1.8.x with this test in place with the following error message:
      #
      # Failures:
      #   1) Puppet::Type::Openldap_config_hash::ProviderOlc when creating
      #   should create an entry in cn=config Failure/Error:
      #   expect(provider.create).to eq(create_ldif_ruby_1_8_7)
      #
      #        expected: "dn: cn=config\nchangetype: modify\nreplace:
      #        olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile:
      #        /etc/ssl/private/key.pem\n-\nadd: olcLogLevel\nolcLogLevel:
      #        stats\n-\nreplace: olcTLSCertificateFile\nolcTLSCertificateFile:
      #        /etc/ssl/certs/cert.pem\n-\n" got: "dn: cn=config\nchangetype:
      #        modify\nreplace: olcTLSCertificateFile\nolcTLSCertificateFile:
      #        /etc/ssl/certs/cert.pem\n-\nreplace:
      #        olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile:
      #        /etc/ssl/private/key.pem\n-\nadd: olcLogLevel\nolcLogLevel:
      #        stats\n-\n"
      #
      #        (compared using ==)
      #
      #        Diff:
      #
      #  @@ -1,12 +1,12 @@
      #   dn: cn=config
      #   changetype: modify
      #  +replace: olcTLSCertificateFile
      #  +olcTLSCertificateFile: /etc/ssl/certs/cert.pem
      #  +-
      #   replace: olcTLSCertificateKeyFile
      #   olcTLSCertificateKeyFile: /etc/ssl/private/key.pem
      #   -
      #   add: olcLogLevel
      #   olcLogLevel: stats
      #  --
      #  -replace: olcTLSCertificateFile
      #  -olcTLSCertificateFile: /etc/ssl/certs/cert.pem
      #   -
      #
      # ./spec/unit/puppet/provider/openldap_config_hash/olc_spec.rb:93

      unless RUBY_VERSION =~ /^1\.8/
        expect(provider.create).to eq(create_ldif)
      end
    end
  end

  describe 'exists?' do
    it 'should return true' do
      provider.class.
        stubs(:slapcat).
        with('(objectClass=olcGlobal)').
        returns(slapcat_output_exists)
      expect(instance.exists?).to be_truthy
    end
  end
end
