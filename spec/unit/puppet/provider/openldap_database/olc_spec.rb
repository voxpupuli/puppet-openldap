# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:openldap_database).provider(:olc) do
  describe '::instances' do
    context 'with all parameters' do
      before do
        expect(described_class).to receive(:slapcat).with('(|(olcDatabase=monitor)(olcDatabase={0}config)(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)(objectClass=olcMdbConfig)(objectClass=olcMonitorConfig)(objectClass=olcRelayConfig)(objectClass=olcLDAPConfig))))').and_return(<<~SLAPCAT)
          dn: olcDatabase={1}mdb,cn=config
          olcDatabase: {1}mdb
          olcReadOnly: FALSE
        SLAPCAT
      end

      it 'parses olcReadOnly' do
        expect(described_class.instances.first.readonly).to be_falsey
      end
    end
  end
end
