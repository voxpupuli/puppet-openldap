# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:openldap_access).provider(:olc) do
  describe '::instances' do
    context 'with Debian defaults' do
      before do
        expect(described_class).to receive(:slapcat).with('(olcAccess=*)').and_return(<<~SLAPCAT)
          # Debian defaults
          dn: olcDatabase={-1}frontend,cn=config
          olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break
          olcAccess: {1}to dn.exact="" by * read
          olcAccess: {2}to dn.base="cn=Subschema" by * read

          dn: olcDatabase={0}config,cn=config
          olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break

          dn: olcDatabase={1}mdb,cn=config
          olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
          olcAccess: {1}to attrs=shadowLastChange by self write by * read
          olcAccess: {2}to * by * read
        SLAPCAT
      end

      it 'parses olcAccess' do
        expect(described_class.instances.size).to eq(7)
      end
    end

    context 'with spaces' do
      before do
        expect(described_class).to receive(:slapcat).with('(olcAccess=*)').and_return(<<~SLAPCAT)
          dn: olcDatabase={-1}frontend,cn=config
          olcAccess: {0}to dn.base="cn=Sub Schema" by * read
        SLAPCAT
      end

      it 'parses olcAccess' do
        expect(described_class.instances.size).to eq(1)
      end
    end
  end
end
