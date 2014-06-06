require 'spec_helper'

describe Puppet::Type.type(:openldap_database) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    @provider_class.stubs(:suitable?).returns true
    described_class.stubs(:defaultprovider).returns @provider_class
  end

  describe "namevar validation" do
    it "should have :suffix as its namevar" do
      described_class.key_attributes.should == [:suffix]
    end
    it "should not invalid suffixes" do
      pending('must implement validation')
      expect { described_class.new(:name => 'foo bar') }.to raise_error(Puppet::Error, /Invalid value/)
      expect { described_class.new(:name => 'cn=admin,dc=example,dc=com') }.to raise_error(Puppet::Error, /Invalid value/)
      expect { described_class.new(:name => 'dc=example, dc=com') }.to raise_error(Puppet::Error, /Invalid value/)
    end
    it "should allow valid suffix" do
      expect { described_class.new(:name => 'dc=example,dc=com') }.to_not raise_error
    end
  end

  describe "when validating attributes" do
    [:suffix, :provider].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end

    [:backend, :directory].each do |property|
      it "should have a #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end

  describe "when validating values" do

    describe "ensure" do
      it "should support present as a value for ensure" do
        expect { described_class.new(:name => 'foo', :ensure => :present) }.to_not raise_error
      end
      it "should support absent as a value for ensure" do
        expect { described_class.new(:name => 'foo', :ensure => :absent) }.to_not raise_error
      end
      it "should not support other values" do
        expect { described_class.new(:name => 'foo', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "backend" do
      it "should support bdb as a value for backend" do
        expect { described_class.new(:name => 'foo', :backend => 'bdb') }.to_not raise_error
      end
      it "should support hdb as a value for backend" do
        expect { described_class.new(:name => 'foo', :backend => 'hdb') }.to_not raise_error
      end
      it "should not support other values" do
        expect { described_class.new(:name => 'foo', :backend => 'bar') }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "directory" do
      it "should support an absolute path as a value for directory" do
        expect { described_class.new(:name => 'foo', :directory => '/bar/baz') }.to_not raise_error
      end
      it "should not support other values" do
        pending('Must implement validation')
        expect { described_class.new(:name => 'foo', :directory => 'bar/baz') }.to raise_error(Puppet::Error, /kjsflkjdsflk/)
      end
    end

  end

end
