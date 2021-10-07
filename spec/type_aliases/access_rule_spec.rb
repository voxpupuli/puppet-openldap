# frozen_string_literal: true

require 'spec_helper'

describe 'Openldap::Access_rule' do
  context 'valid value' do
    [
      'by dn="cn=admin,dc=example,dc=com write',
      'by anonymous auth',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end
end
