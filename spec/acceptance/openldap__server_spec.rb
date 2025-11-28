# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openldap::server' do
  context 'with defaults' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'openldap::server': }
      EOS

      idempotent_apply(pp)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.not_to be_listening }
    end
  end

  context 'when adding certificates' do
    it 'with cert, key and ca' do
      pp = <<-EOS
        class { 'openldap::server':
          ssl_key   => "/etc/ldap/ssl/${facts['networking']['fqdn']}.key",
          ssl_cert  => "/etc/ldap/ssl/${facts['networking']['fqdn']}.crt",
          ssl_ca    => '/etc/ldap/ssl/ca.pem',
        }
      EOS

      idempotent_apply(pp)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.not_to be_listening }
    end

    it 'can connect with ldapsearch using StartTLS' do
      ldapsearch('-LLL -x -b dc=example,dc=com -ZZ') do |r|
        expect(r.stdout).to match(%r{dn: dc=example,dc=com})
      end
    end
  end

  context 'when enabling ldaps' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'openldap::server':
          ldaps_ifs => ['/'],
          ssl_key   => "/etc/ldap/ssl/${facts['networking']['fqdn']}.key",
          ssl_cert  => "/etc/ldap/ssl/${facts['networking']['fqdn']}.crt",
          ssl_ca    => '/etc/ldap/ssl/ca.pem',
        }
      EOS

      idempotent_apply(pp)
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.to be_listening }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    it 'can connect with ldapsearch using ldaps:///' do
      ldapsearch('-LLL -x -b dc=example,dc=com -H ldaps:///') do |r|
        expect(r.stdout).to match(%r{dn: dc=example,dc=com})
      end
    end
  end

  skip('Does not work on openldap 2.4') if (fact('os.family') == 'Debian' && fact('os.release.major') == 11) ||
                                           (fact('os.family') == 'RedHat' && fact('os.release.major') == 8)
  context 'when enabling PROXY Protocol' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'openldap::server':
          ldaps_ifs  => ['/'],
          ssl_key    => "/etc/ldap/ssl/${facts['networking']['fqdn']}.key",
          ssl_cert   => "/etc/ldap/ssl/${facts['networking']['fqdn']}.crt",
          ssl_ca     => '/etc/ldap/ssl/ca.pem',
          pldaps_ifs => ['[::]:3269/'],
          pldap_ifs  => ['[::]:7389/'],
        }
      EOS

      idempotent_apply(pp)
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    describe port(7389) do
      it { is_expected.to be_listening }
    end

    describe port(3269) do
      it { is_expected.to be_listening }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end
end
