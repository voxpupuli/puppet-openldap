# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:openldap_access) do
  describe 'access' do
    it 'handles array of values' do
      access = described_class.new(name: '0 on dc=example,dc=com', access: ['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth'])
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write'], ['by anonymous auth']])
    end

    it 'handles string' do
      access = described_class.new(name: '0 on dc=example,dc=com', access: 'by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end

    it 'handles target with spaces with prefix' do
      access = described_class.new(name: '0 on dn.subtree="cn=Some String,dc=example,dc=com"', access: 'by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end

    it 'handles target with spaces without prefix' do
      access = described_class.new(name: '0 on "cn=Some String,dc=example,dc=com"', access: 'by dn="cn=admin,dc=example,dc=com" write by anonymous auth')
      expect(access[:access]).to eq([['by dn="cn=admin,dc=example,dc=com" write', 'by anonymous auth']])
    end
  end
end
