require 'spec_helper'

describe Puppet::Type.type(:openldap_dbindex) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    @provider_class.stubs(:suitable?).returns true
    described_class.stubs(:defaultprovider).returns @provider_class
  end
  describe "namevar validation" do
    it "should have :name and :suffix in its namevar" do
      expect(described_class.key_attributes).to eq([:name, :suffix])
    end
    it "should have namevar eq ':name on :suffix'" do
      #expect { described_class.new(:name => 'cn', :suffix => 'dc=example,dc=com')[:title] }.to eq ['cn on dc=example,dc=com']
      pending 'WIP'
    end
  end
end
