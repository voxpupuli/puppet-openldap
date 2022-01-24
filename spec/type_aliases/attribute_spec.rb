# frozen_string_literal: true

require 'spec_helper'

describe 'Openldap::Attribute' do
  context 'valid values' do
    [
      'objectClass: inetOrgPerson',
      'olcThreads: 16',
      'olcReadOnly: FALSE',
    ].each do |value|
      context value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  context 'invalid values' do
    [
      'objectClass:',
      'objectClass: ',
      '42',
      nil,
      42,
      true,
      false,
    ].each do |value|
      context value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
