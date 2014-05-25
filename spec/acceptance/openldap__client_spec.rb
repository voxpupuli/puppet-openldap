require 'spec_helper_acceptance'

describe 'openldap::client class' do

  describe 'without parameter' do
    it 'should install client' do
      pp = <<-EOS
        class { 'openldap::client': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

end

