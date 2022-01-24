# frozen_string_literal: true

require 'spec_helper'

describe 'openldap::server::schema' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without parameter' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
