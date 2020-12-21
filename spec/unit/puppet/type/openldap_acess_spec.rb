require 'spec_helper'

describe Puppet::Type.type(:openldap_access) do
  describe 'namevar title patterns' do
    it 'handles componsite name' do
      access = described_class.new(name: 'to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:name]).to eq('to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:what]).to eq('attrs=userPassword,shadowLastChange')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end

    it 'handles componsite name with position' do
      access = described_class.new(name: '{0}to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:name]).to eq('{0}to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:position]).to eq('0')
      expect(access[:what]).to eq('attrs=userPassword,shadowLastChange')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end

    it 'handles componsite name with position' do
      access = described_class.new(name: '{0}to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth on dc=example,dc=com')
      expect(access[:name]).to eq('{0}to attrs=userPassword,shadowLastChange by dn="cn=admin,dc=example,dc=com" write by anonymous auth on dc=example,dc=com')
      expect(access[:position]).to eq('0')
      expect(access[:what]).to eq('attrs=userPassword,shadowLastChange')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
      expect(access[:suffix]).to eq('dc=example,dc=com')
    end

    it 'handles specific value of attr' do
      access = described_class.new(name: 'to attrs=objectClass val=posixAccount by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:name]).to eq('to attrs=objectClass val=posixAccount by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:what]).to eq('attrs=objectClass val=posixAccount')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end
  end

  describe 'access' do
    it 'handles array of values' do
      access = described_class.new(name: 'foo', access: ['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth'])
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write'], ['by anonymous auth']])
    end

    it 'handles string' do
      access = described_class.new(name: 'foo', access: 'by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end
  end
end
