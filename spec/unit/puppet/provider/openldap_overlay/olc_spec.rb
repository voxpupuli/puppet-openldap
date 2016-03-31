require 'spec_helper'

describe Puppet::Type.type(:openldap_overlay).provider(:olc) do

  let(:params) do
    {
      :title    => 'memberof on dc=example,dc=com',
      :name     => 'memberof on dc=example,dc=com',
      :overlay  => 'memberof',
      :suffix   => 'dc=example,dc=com',
      :provider => described_class.name
    }
  end

  let(:params_suffix) do
    'dc=example,dc=com'
  end

  let(:ldif_create) do
    <<-EOS
dn: olcOverlay=memberof,dc=example,dc=com
changetype: add
objectClass: olcConfig
objectClass: olcOverlayConfig
objectClass: olcMemberOf
olcOverlay: memberof
EOS
  end

  let(:resource) do
    Puppet::Type.type(:openldap_overlay).new(params)
  end

  let(:provider) do
    resource.provider
  end

  before do
    provider.stubs(:slapcat).returns('foo')
    provider.stubs(:ldapmodify).returns(0)
  end

  describe 'when creating' do
    it 'should create an overlay' do
      provider.stubs(:getDn).returns(params_suffix)
      expect(provider.create).to eq ldif_create
    end
  end

  describe 'when removing or changing an entry (Ruby 1.8.7)' do
    it 'should not throw the error "Could not evaluate: undefined method `keys\' for []:Array"' do
      provider.options = { :foo => 'a' }
      expect { provider.flush() }.not_to raise_error("Could not evaluate: undefined method `keys' for []:Array")
    end
  end
end
