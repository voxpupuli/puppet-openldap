# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/InstanceVariable
describe Puppet::Type.type(:openldap_database) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    allow(@provider_class).to receive(:suitable?).and_return(true)
    allow(described_class).to receive(:defaultprovider).and_return(@provider_class)
  end

  describe 'namevar validation' do
    it 'has :suffix as its namevar' do
      expect(described_class.key_attributes).to eq([:suffix])
    end

    it 'does not invalid suffixes' do
      expect { described_class.new(name: 'foo bar') }.to raise_error(Puppet::Error, %r{Invalid value})
      expect { described_class.new(name: 'cn=admin,dc=example,dc=com') }.to raise_error(Puppet::Error, %r{Invalid value})
      expect { described_class.new(name: 'dc=example, dc=com') }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'allows valid suffix' do
      expect { described_class.new(name: 'dc=example,dc=com') }.not_to raise_error
      expect { described_class.new(name: 'cn=config') }.not_to raise_error
    end
  end

  describe 'when validating attributes' do
    %i[suffix provider].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    %i[backend directory].each do |property|
      it "has a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe 'when validating values' do
    describe 'ensure' do
      it 'supports present as a value for ensure' do
        expect { described_class.new(name: 'dc=foo', ensure: :present) }.not_to raise_error
      end

      it 'supports absent as a value for ensure' do
        expect { described_class.new(name: 'dc=foo', ensure: :absent) }.not_to raise_error
      end

      it 'does not support other values' do
        expect { described_class.new(name: 'dc=foo', ensure: :foo) }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'backend' do
      %w[bdb hdb mdb monitor config relay ldap].each do |b|
        it "supports #{b} as a value for backend" do
          expect { described_class.new(name: 'dc=foo', backend: b) }.not_to raise_error
        end
      end
      it 'supports config as a value for backend' do
        expect { described_class.new(name: 'dc=foo', backend: 'config') }.not_to raise_error
      end

      it 'does not support other values' do
        expect { described_class.new(name: 'dc=foo', backend: 'bar') }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'directory' do
      it 'supports an absolute path as a value for directory' do
        expect { described_class.new(name: 'dc=foo', directory: '/bar/baz') }.not_to raise_error
      end

      it 'does not support other values' do
        expect { described_class.new(name: 'dc=foo', directory: 'bar/baz') }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end
  end

  describe 'rootpw' do
    before do
      @resource = described_class.new(name: 'dc=foo')
      @password = described_class.attrclass(:rootpw).new(resource: @resource, should: 'secret')
    end

    it 'does not include the password in the change log when adding the password' do
      expect(@password.change_to_s(:absent, 'secret')).not_to be_include('secret')
    end

    it 'does not include the password in the change log when changing the password' do
      expect(@password.change_to_s('oldpass', 'secret')).not_to be_include('secret')
    end

    it 'redacts the password when displaying the old value' do
      expect(@password.is_to_s('oldpass')).to match(%r{^\[old password hash redacted\]$})
    end

    it 'redacts the password when displaying the new value' do
      expect(@password.should_to_s('newpass')).to match(%r{^\[new password hash redacted\]$})
    end
  end

  describe 'organization' do
    it 'sets organization to foo.bar' do
      @resource = described_class.new(name: 'foo', suffix: 'dc=foo,dc=bar')
      expect(@resource[:organization]).to eq('foo.bar')
    end

    it 'is nil when suffix is not using dc' do
      @resource = described_class.new(name: 'foo', suffix: 'o=foo,dc=bar')
      expect(@resource[:organization]).to be_nil
    end
  end
end
# rubocop:enable RSpec/InstanceVariable
