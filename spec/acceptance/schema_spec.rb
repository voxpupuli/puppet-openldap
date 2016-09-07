require 'spec_helper_acceptance'

describe 'openldap::server::schema' do

  context 'without parameters' do
    it 'creates an overlay' do
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::schema { 'misc':
        ensure => present,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end


