# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Puppet::Type.type(:openldap_overlay).provider(:olc) do
  describe 'instances' do
    describe 'ppolicy' do
      before do
        slapcat_overlay_output = <<~OUTPUT
          dn: olcOverlay={1}ppolicy,olcDatabase={2}mdb,cn=config
          objectClass: olcConfig
          objectClass: olcOverlayConfig
          objectClass: olcPPolicyConfig
          olcOverlay: {1}ppolicy
          olcPPolicyDefault: cn=default_password_policy,ou=policies,dc=example,dc=com
          olcPPolicyHashCleartext: FALSE
          olcPPolicyUseLockout: FALSE
          olcPPolicyForwardUpdates: FALSE
          structuralObjectClass: olcPPolicyConfig
          entryUUID: db7e0900-7457-103f-9aab-a3df2413523b
          creatorsName: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
          createTimestamp: 20250131194650Z
          entryCSN: 20250131194650.121815Z#000000#000#000000
          modifiersName: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
          modifyTimestamp: 20250131194650Z
        OUTPUT
        slapcat_db_output = <<~OUTPUT
          dn: olcDatabase={2}mdb,cn=config
          objectClass: olcDatabaseConfig
          objectClass: olcMdbConfig
          olcDatabase: {2}mdb
          olcSuffix: dc=example,dc=com
        OUTPUT
        allow(described_class).to receive(:slapcat).with(
          '(olcOverlay=*)'
        ).and_return(slapcat_overlay_output)
        allow(described_class).to receive(:slapcat).with(
          '(olcDatabase={2}mdb)'
        ).and_return(slapcat_db_output)
      end

      it 'reads a ppolicy object' do
        expect(described_class.instances.size).to eq(1)
        expect(described_class.instances[0].name).to eq('ppolicy on dc=example,dc=com')
        expect(described_class.instances[0].overlay).to eq('ppolicy')
        expect(described_class.instances[0].suffix).to eq('dc=example,dc=com')
        expect(described_class.instances[0].index).to eq(1)
        expect(described_class.instances[0].options).to eq(
          {
            'olcPPolicyDefault'        => 'cn=default_password_policy,ou=policies,dc=example,dc=com',
            'olcPPolicyHashCleartext'  => 'FALSE',
            'olcPPolicyUseLockout'     => 'FALSE',
            'olcPPolicyForwardUpdates' => 'FALSE',
          }
        )
      end
    end

    describe 'chain' do
      before do
        slapcat_overlay_output = <<~OUTPUT
          dn: olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config
          objectClass: olcConfig
          objectClass: olcOverlayConfig
          objectClass: olcChainConfig
          olcOverlay: {0}chain
          olcChainCacheURI: FALSE
          olcChainMaxReferralDepth: 1
          olcChainReturnError: TRUE
        OUTPUT
        slapcat_db_output = <<~OUTPUT
          dn: olcDatabase={-1}frontend,cn=config
          objectClass: olcDatabaseConfig
          objectClass: olcFrontendConfig
          olcDatabase: {-1}frontend
        OUTPUT
        allow(described_class).to receive(:slapcat).with(
          '(olcOverlay=*)'
        ).and_return(slapcat_overlay_output)
        allow(described_class).to receive(:slapcat).with(
          '(olcDatabase={-1}frontend)'
        ).and_return(slapcat_db_output)
      end

      it 'reads a chain object' do
        expect(described_class.instances.size).to eq(1)
        expect(described_class.instances[0].name).to eq('chain on cn=frontend')
        expect(described_class.instances[0].overlay).to eq('chain')
        expect(described_class.instances[0].suffix).to eq('cn=frontend')
        expect(described_class.instances[0].index).to eq(0)
        expect(described_class.instances[0].options).to eq(
          {
            'olcChainCacheURI'         => 'FALSE',
            'olcChainMaxReferralDepth' => '1',
            'olcChainReturnError'      => 'TRUE',
          }
        )
      end
    end
  end

  describe 'creating overlay' do
    let(:params) do
      {
        title: 'memberof on dc=example,dc=com',
        overlay: 'memberof',
        suffix: 'dc=example,dc=com',
        provider: described_class.name,
      }
    end

    let(:resource) do
      Puppet::Type.type(:openldap_overlay).new(params)
    end

    let(:provider) do
      resource.provider
    end

    let(:tmpfile) { instance_spy(Tempfile) }
    let(:tmpfile_path) { double }
    let(:tmpfile_content) { double }

    before do
      allow(provider).to receive(:slapcat).and_return('foo')
      allow(Tempfile).to receive(:new).and_return(tmpfile)
      allow(tmpfile).to receive(:path).and_return(tmpfile_path)
      allow(IO).to receive(:read).with(tmpfile_path).and_return(tmpfile_content)
      allow(Puppet).to receive(:debug).with(tmpfile_content)
      allow(provider).to receive(:ldapmodify)
    end

    describe 'when creating' do
      before do
        allow(provider).to receive(:getDn).and_return('dc=example,dc=com')
      end

      it 'creates an overlay' do
        provider.create
        expect(tmpfile).to have_received(:<<).with("dn: olcOverlay=memberof,dc=example,dc=com\n")
        expect(tmpfile).to have_received(:<<).with("objectClass: olcMemberOf\n")
        expect(tmpfile).to have_received(:<<).with("olcOverlay: memberof\n")
        expect(provider).to have_received(:ldapmodify)
      end
    end

    describe 'with smbk5pwd' do
      before do
        allow(provider).to receive(:getDn).and_return('dc=example,dc=com')
      end

      let(:params) do
        {
          title: 'smbk5pwd on dc=example,dc=com',
          options: {
            'olcSmbK5PwdEnable' => %w[samba shadow],
          },
        }
      end

      describe 'when creating' do
        it 'creates an overlay' do
          provider.create
          expect(tmpfile).to have_received(:<<).with("dn: olcOverlay=smbk5pwd,dc=example,dc=com\n")
          expect(tmpfile).to have_received(:<<).with("objectClass: olcSmbK5PwdConfig\n")
          expect(tmpfile).to have_received(:<<).with("olcOverlay: smbk5pwd\n")
          expect(tmpfile).to have_received(:<<).with("olcSmbK5PwdEnable: samba\nolcSmbK5PwdEnable: shadow\n")
          expect(provider).to have_received(:ldapmodify)
        end
      end
    end

    describe 'with chain' do
      let(:params) do
        {
          title: 'chain on cn=frontend',
          suffix: 'cn=frontend',
          options: {
            'olcChainMaxReferralDepth' => '1',
          },
        }
      end

      describe 'when creating' do
        it 'creates an overlay' do
          provider.create
          expect(tmpfile).to have_received(:<<).with("dn: olcOverlay=chain,olcDatabase={-1}frontend,cn=config\n")
          expect(tmpfile).to have_received(:<<).with("objectClass: olcChainConfig\n")
          expect(tmpfile).to have_received(:<<).with("olcOverlay: chain\n")
          expect(tmpfile).to have_received(:<<).with("olcChainMaxReferralDepth: 1\n")
          expect(provider).to have_received(:ldapmodify)
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
