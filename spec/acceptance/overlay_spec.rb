# frozen_string_literal: true

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

      idempotent_apply(pp)
    end
  end

  context 'options defined' do
    it 'adds option to overlay' do
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
        ensure  => present,
        options => {
          'olcMemberOfGroupOC' => 'groupOfNames',
        }
      }
      EOS

      idempotent_apply(pp)
    end
  end

  context 'cleanup' do
    it 'adds option to overlay' do
      pp = <<-EOS
      class { 'openldap::server': }
      openldap::server::database { 'dc=foo,dc=bar':
        ensure => present,
      }
      openldap::server::overlay { 'memberof on dc=foo,dc=bar':
        ensure  => absent,
      }
      EOS

      idempotent_apply(pp)
    end
  end
end
