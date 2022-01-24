# frozen_string_literal: true

require 'spec_helper'

describe 'Openldap::Access_hash' do
  context 'valid types' do
    [
      {
        '0 on dc=example,dc=com' => {
          'what' => 'attrs=userPassword,shadowLastChange',
          'access' => [
            'by dn="cn=admin,dc=example,dc=com" write',
            'by anonymous auth',
            'by self write',
            'by * none',
          ],
        },
      },
      {
        '0 on dc=example,dc=com' => {
          'position' => 3,
          'suffix' => 'dc=example,dc=com',
          'what' => 'attrs=userPassword,shadowLastChange',
          'access' => [
            'by dn="cn=admin,dc=example,dc=com" write',
            'by anonymous auth',
            'by self write',
            'by * none',
          ],
        },
      },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end
end
