# frozen_string_literal: true

Puppet::Type.newtype(:openldap_global_conf) do
  ensurable

  newparam(:name)

  newparam(:target)

  newproperty(:value) do
    validate do |value|
      raise Puppet::Error, 'value should be a String or a Hash' unless [String, Hash].include? value.class
    end
  end
end
