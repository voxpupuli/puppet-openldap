Puppet::Type.newtype(:openldap_dbtree) do
  @doc = "Manages OpenLDAP database base trees."

  ensurable

  newparam(:tree, :namevar => true) do
    desc "The tree to generate."
  end

  newparam(:suffix) do
    desc "The database suffix."
  end
end
