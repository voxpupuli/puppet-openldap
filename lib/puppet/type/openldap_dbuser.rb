Puppet::Type.newtype(:openldap_dbuser) do
  @doc = "Manages OpenLDAP system user accounts."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The default name variable."
  end

  newparam(:suffix) do
    desc "The suffix of the target database."
  end

  newparam(:user) do
    desc "The user account CN attribute value."
  end

  newparam(:passwd) do
    desc "The password to set for the administrator account."
  end
end
