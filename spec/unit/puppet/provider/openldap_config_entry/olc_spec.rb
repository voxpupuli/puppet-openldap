require 'spec_helper'

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. .. lib puppet_x openldap pw_hash.rb]))

describe Puppet::Type.type(:openldap_config_entry).provider(:olc) do

  let(:params) do
    {
      :title    => 'Security-18dec4827672e3bbe0f4bfb89be49936',
      :key      => 'Security',
      :value    => 'tls=128',
      :ensure   => :present,
    }
  end

  let(:slapcat_output_exists) do
    <<-LDIF
dn: cn=config
olcSecurity: tls=128
LDIF
  end

  let(:create_ldif) do
    <<-LDIF
dn: cn=config
changetype: modify
replace: olc#{params[:key]}
olc#{params[:key]}: #{params[:value]}
LDIF
  end

  let(:resource) do
    Puppet::Type.type(:openldap_config_entry).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:instance) { provider.class.instances.first }

  before do
  end

  describe 'self.instances' do
    it 'returns an array of cn=config entry resources' do
      # NOTE: The provider calls a function in the base provider, so it does not provide a command itself anymore.
      provider.class.
        stubs(:slapcat).
        with('(objectClass=olcGlobal)').
        returns(slapcat_output_exists)

      instance = provider.class.instances.first

      # irb(main):001:0> require 'digest/md5'
      # irb(main):002:0> Digest::MD5.hexdigest("tls=128-openldapadditionalconfig")
      # => "2d8a2d779763deb537847b94b708f465"

      expected_title = 'Security-2d8a2d779763deb537847b94b708f465'

      expect(expected_title).to  match(instance.name)
      expect('Security').to      match(instance.key)
      expect('tls=128').to       match(instance.value)
      expect(:present).to        match(instance.ensure)
    end
  end

  describe 'when creating' do
    it 'should create an entry in cn=config' do
      provider.stubs(:ldapmodify).returns(0)
      expect(provider.create).to eq(create_ldif)
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
