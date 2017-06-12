Puppet::Type.newtype(:openldap_dbtree) do
  @doc = "Manages OpenLDAP database base trees."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The resource name."
  end

  newparam(:suffix) do
    desc "The database suffix."
  end

  newparam(:tree) do
    desc "The tree DN to ensure."
  end
end
