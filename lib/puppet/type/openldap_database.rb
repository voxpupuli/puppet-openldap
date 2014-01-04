Puppet::Type.newtype(:openldap_database) do
  @doc = "Manages OpenLDAP BDB and HDB databases."

  ensurable

  newparam(:suffix) do
    isnamevar
    desc "The default namevar."
  end

  newparam(:target) do
  end

  newparam(:index) do
    desc "The index of the database."
  end

  newparam(:backend) do
    desc "The name of the backend."
    newvalues('bdb', 'hdb')
    defaultto('hdb')
  end

  newproperty(:directory) do
  end

  newproperty(:rootdn) do
  end

  newproperty(:rootpw) do
  end

end
