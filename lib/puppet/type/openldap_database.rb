Puppet::Type.newtype(:openldap_database) do
  @doc = "Manages OpenLDAP BDB and HDB databases."

  ensurable

  newparam(:suffix, :namevar => true) do
    desc "The default namevar."
  end

  newparam(:target) do
  end

  newproperty(:index) do
    desc "The index of the database."
  end

  newproperty(:backend) do
    desc "The name of the backend."
    newvalues('bdb', 'hdb')
    case Facter.value(:osfamily)
    when 'Debian'
      defaultto('hdb')
    when 'RedHat'
      defaultto('bdb')
    end
  end

  newproperty(:directory) do
    desc "The directory where the BDB files containing this database and associated indexes live."
  end

  newproperty(:rootdn) do
    desc "The distinguished name that is not subject to access control or administrative limit restrictions for operations on this database."
  end

  newproperty(:rootpw) do
    desc "Password (or hash of the password) for the rootdn."
  end

end
