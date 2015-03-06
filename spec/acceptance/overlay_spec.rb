require 'spec_helper_acceptance'

describe 'openldap::server::overlay' do

  context 'without parameters' do
    it 'creates an overlay' do
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=bar':
        ensure => present,
      }
      ->
      openldap::server::module { 'memberof':
        ensure => present,
      }
      ->
      openldap::server::overlay { 'memberof on dc=foo,dc=bar':
        ensure => present,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      #apply_manifest(pp, :catch_changes => true)
    end
  end
end


