# frozen_string_literal: true

require 'spec_helper'

describe 'Openldap::Access_title' do
  context 'valid value' do
    [
      '0 on dc=example,dc=com',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end
end
