Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
  end

  newparam(:position) do
  end

  newproperty(:access) do
  end

  newproperty(:suffix) do
  end

end
