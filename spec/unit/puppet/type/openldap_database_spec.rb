#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:openldap_database) do
  describe 'without parameters' do
    resource = Puppet::Type.type(:openldap_database).new :title => 'dc=example,dc=com'
    it 'should have :suffix be its namevar' do
      resource[:suffix].should == 'dc=example,dc=com'
    end
    it 'should have :backend be set to hdb' do
      resource[:backend].should == :hdb
    end
    it 'should have :rootdn be set to nil' do
      resource[:rootdn].should == nil
    end
    it 'should have :rootpw be set to nil' do
      resource[:rootpw].should == nil
    end
  end
end
