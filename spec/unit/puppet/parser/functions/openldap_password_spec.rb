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
    it 'should generate password' do
      scope.stubs(:function_fqdn_rand_string).with([8]).returns('abcdefgh')
      expect(scope.function_openldap_password(['foo'])).to eq("{SSHA}3RXLE64s+3ytIRdJYu9eoU8O/alhYmNkZWZnaA==")
    end
  end

  context 'when given a secret and a scheme' do
    it 'should generate CRYPT password' do
      scope.stubs(:function_fqdn_rand_string).with([2]).returns('ab')
      expect(scope.function_openldap_password(['foo', 'CRYPT'])).to eq("{CRYPT}abQ9KY.KfrYrc")
    end
    it 'should generate MD5 password' do
      expect(scope.function_openldap_password(['foo', 'MD5'])).to eq("{MD5}acbd18db4cc2f85cedef654fccc4a4d8")
    end
    it 'should generate SMD5 password' do
      scope.stubs(:function_fqdn_rand_string).with([8]).returns('abcdefgh')
      expect(scope.function_openldap_password(['foo', 'SMD5'])).to eq("{SMD5}NAYSvQYSIRYBLCM8U6MUc2FiY2RlZmdo")
    end
    it 'should generate SSHA password' do
      scope.stubs(:function_fqdn_rand_string).with([8]).returns('abcdefgh')
      expect(scope.function_openldap_password(['foo', 'SSHA'])).to eq("{SSHA}3RXLE64s+3ytIRdJYu9eoU8O/alhYmNkZWZnaA==")
    end
    it 'should generate SHA password' do
      expect(scope.function_openldap_password(['foo', 'SHA'])).to eq("{SHA}0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
    end
  end
end
