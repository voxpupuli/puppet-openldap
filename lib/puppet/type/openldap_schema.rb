Puppet::Type.newtype(:openldap_schema) do
  @doc = "Manages OpenLDAP schemas."

  ensurable

  newparam(:name) do
    desc "The default namevar."
  end

  newparam(:path) do
    desc "The location to the schema file."
  end

end
