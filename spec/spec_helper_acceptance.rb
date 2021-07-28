# This file is completely managed via modulesync
require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

def idempotent_apply(pp)
  apply_manifest(pp, catch_failures: true)
  apply_manifest(pp, catch_changes: true)
end

def ldapsearch(_cmd, _exit_codes = [0, 1])
  puts 'shell() not working in litmus for now'
  # shell("ldapsearch #{cmd}", acceptable_exit_codes: exit_codes, &block)
end

RSpec.configure do |c|
  c.before :suite do
    pp = <<-EOS
     package { 'ssl-cert':
       ensure => installed,
     }
     file { '/etc/ldap':
       ensure => directory,
     }
     file { '/etc/ldap/ssl':
       ensure => directory,
     }
     file { "/etc/ldap/ssl/${::fqdn}.key":
       ensure  => file,
       mode    => '0644',
       source  => "/etc/ssl/private/ssl-cert-snakeoil.key",
     }
     file { "/etc/ldap/ssl/${::fqdn}.crt":
       ensure  => file,
       mode    => '0644',
       source  => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
     }
     file { '/etc/ldap/ssl/ca.pem':
       ensure  => file,
       mode    => '0644',
       source  => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
     }
    EOS

    idempotent_apply(pp)
  end
end

Dir['./spec/support/acceptance/**/*.rb'].sort.each { |f| require f }
