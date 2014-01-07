Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
  end

  newparam(:position) do
  end

  newproperty(:suffix) do
  end

  newproperty(:what) do
  end

  newproperty(:by, :array_matching => :all) do
  end

  newparam(:target) do
  end

end
