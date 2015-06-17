Puppet::Type.newtype(:openldap_schema) do
  @doc = "Manages OpenLDAP schemas."

  ensurable

  newparam(:name) do
    desc "The default namevar."
  end

  newparam(:path) do
    desc "The location to the schema file."
  end

  newparam(:converttoldif, :boolean => true) do
    desc "Convert legacy schema file to ldif format"
    defaultto :true
  end

end
