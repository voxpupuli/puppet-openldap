Puppet::Type.newtype(:openldap_global_conf) do

  ensurable

  newparam(:name) do
  end

  newparam(:target) do
  end

  newproperty(:value) do
    validate do |value|
      raise Puppet::Error, 'value should be a String, Hash or Array' unless [String, Hash, Array].include? value.class
    end
  end

end
