require 'spec_helper'

describe Puppet::Parser::Functions.function(:openldap_password) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function('openldap_password')).to eq('function_openldap_password')
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
      Puppet::Util::Execution.stubs(:execute).with([
        'slappasswd', '-s', 'foo'
      ]).returns("{SSHA}kKSBVuPOwlHp5HfcR3LBKyB7smTnbq9Y\n")
      expect(scope.function_openldap_password(['foo'])).to eq('{SSHA}kKSBVuPOwlHp5HfcR3LBKyB7smTnbq9Y')
    end
  end

  context 'when given a secret and a scheme' do
    it 'should execute slappasswd on them' do
      Puppet::Util::Execution.stubs(:execute).with([
        'slappasswd', '-s', 'foo', '-h', '{MD5}'
      ]).returns("{MD5}rL0Y20zC+Fzt72VPzMSk2A==\n")
      expect(scope.function_openldap_password(['foo', '{MD5}'])).to eq('{MD5}rL0Y20zC+Fzt72VPzMSk2A==')
    end
  end
end
