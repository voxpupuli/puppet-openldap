require 'spec_helper'

describe Puppet::Parser::Functions.function(:openldap_password) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        facts.each do |k, v|
          scope.stubs(:lookupvar).with("::#{k}").returns(v)
          scope.stubs(:lookupvar).with(k).returns(v)
        end
      end

      it 'should exist' do
        expect(
          Puppet::Parser::Functions.function('openldap_password')
        ).to eq('function_openldap_password')
      end

      context 'when given a wrong number of arguments' do
        it 'should fail' do
          expect {
            scope.function_openldap_password([])
          }.to raise_error Puppet::ParseError, /Wrong number of arguments given/
        end
      end

      context 'when given only a secret' do
        it 'should return the SSHA of the password with sha1("foo.example.com") as salt' do
          expect(
            scope.function_openldap_password(['secret'])
          ).to eq('{SSHA}jZdUkbyDYvmpSKg0x/k879g+RY7EHbws5g==')
        end
      end
    end
  end
end
