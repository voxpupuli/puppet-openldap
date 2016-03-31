Puppet::Type.newtype(:openldap_config_hash) do

  ensurable

  newparam(:name) do
  end

  newparam(:target) do
  end

  newproperty(:value) do
    validate do |value|
      raise Puppet::Error, 'value should be a Hash' unless value.is_a?(Hash)
    end
  end

end
