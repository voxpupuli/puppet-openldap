# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:openldap_database).provider(:olc) do
  let(:params) do
    {
      title: 'dc=example,dc=com',
      backend: 'mdb',
      provider: described_class.name,
    }
  end

  let(:resource) do
    Puppet::Type.type(:openldap_database).new(params)
  end

  let(:provider) do
    resource.provider
  end

  before do
    allow(described_class).to receive(:slapcat).with('(|(olcDatabase=monitor)(olcDatabase={0}config)(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)(objectClass=olcMdbConfig)(objectClass=olcMonitorConfig)(objectClass=olcRelayConfig)(objectClass=olcLDAPConfig))))').and_return(<<~SLAPCAT)
      dn: olcDatabase={1}mdb,cn=config
      olcDatabase: {1}mdb
      olcReadOnly: FALSE
    SLAPCAT
  end

  describe '::instances' do
    context 'with all parameters' do
      it 'parses olcReadOnly' do
        expect(described_class.instances.first.readonly).to eq(:false)
      end
    end

    context 'with readonly set to true' do
      let(:params) do
        {
          readonly: true
        }
      end

      it 'parses olcReadonly' do
        provider.create
        expect(described_class.instances.first.readonly).to eq(:true)
      end
    end
  end
end
