# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Puppet::Type.type(:openldap_overlay).provider(:olc) do
  let(:params) do
    {
      title: 'memberof on dc=example,dc=com',
      name: 'memberof on dc=example,dc=com',
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
    allow(provider).to receive(:getDn).and_return('dc=example,dc=com')
    allow(provider).to receive(:ldapmodify)
  end

  describe 'when creating' do
    it 'creates an overlay' do
      provider.create
      expect(tmpfile).to have_received(:<<).with("dn: olcOverlay=memberof,dc=example,dc=com\n")
      expect(tmpfile).to have_received(:<<).with("objectClass: olcMemberOf\n")
      expect(tmpfile).to have_received(:<<).with("olcOverlay: memberof\n")
      expect(provider).to have_received(:ldapmodify)
    end
  end

  describe 'with smbk5pwd' do
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
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
