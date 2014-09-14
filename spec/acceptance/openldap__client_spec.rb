require 'spec_helper_acceptance'

describe 'openldap::client class' do

  describe 'without parameter' do
    it 'should install client' do
      pp = <<-EOS
        class { 'openldap::client': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end

