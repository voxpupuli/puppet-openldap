require 'spec_helper'

describe Puppet::Parser::Functions.function(:openldap_password) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function('openldap_password').should == 'function_openldap_password'
  end

  context 'when given a wrong number of arguments' do
    it 'should fail' do
      expect {
        scope.function_openldap_password([])
      }.to raise_error Puppet::ParseError, /Wrong number of arguments given/
    end
  end

  context 'when given only a secret' do
    it 'should execute slappasswd on it' do
      Puppet::Util::Execution.expects(:execute).with([
        'slappasswd', '-s', 'foo'
        ])
      scope.function_openldap_password(['foo'])
    end
  end

  context 'when given a secret and a scheme' do
    it 'should execute slappasswd on them' do
      Puppet::Util::Execution.expects(:execute).with([
        'slappasswd', '-s', 'foo', '-h', 'bar'
        ])
      scope.function_openldap_password(['foo', 'bar'])
    end
  end
end
