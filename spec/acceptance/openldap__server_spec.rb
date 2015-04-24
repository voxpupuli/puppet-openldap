require 'spec_helper_acceptance'

describe 'openldap::server' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'openldap::server': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(389) do
      it { is_expected.to be_listening }
    end

    describe port(636) do
      it { is_expected.not_to be_listening }
    end
  end
end
