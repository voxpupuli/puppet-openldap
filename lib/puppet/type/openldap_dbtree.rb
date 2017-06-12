Puppet::Type.newtype(:openldap_dbtree) do
  @doc = "Manages OpenLDAP database base trees."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The default name variable."
  end

  newparam(:suffix) do
    desc "The database suffix."
  end

  newparam(:tree) do
    desc "The database tree, i.e. ou=<tree>,<suffix>"
  end
end
