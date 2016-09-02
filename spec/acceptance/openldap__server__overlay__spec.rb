require 'spec_helper_acceptance'

describe 'openldap::server::overlay' do

  context 'without parameters' do
    it 'creates an overlay' do
      pp = <<-EOS
        $opnldap_overlay = { 'syncprov on dc=foo,dc=bar' => { 'ensure' => 'present', 'options' => { 'olcSpCheckpoint' => '100 10', 'olcSpSessionLog' => '100' }} ,  'ppolicy on dc=foo,dc=bar'  => { 'ensure' => 'present', 'options' => { 'olcPPolicyForwardUpdates' => 'FALSE', 'olcPPolicyUseLockout' => 'FALSE', 'olcPPolicyHashCleartext' => 'FALSE', 'olcPPolicyDefault' => 'cn=bojo,ou=policies,dc=foo,dc=bar'}}}
        class { 'openldap::server': }
        openldap::server::database { 'dc=foo,dc=bar':
          ensure => present,
        }
        openldap::server::module { 'syncprov':
          ensure => present,
        }
        openldap::server::module { 'ppolicy':
          ensure => present,
        }
        create_resources('::openldap::server::overlay', $opnldap_overlay)
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end


