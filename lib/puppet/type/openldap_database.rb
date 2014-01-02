Puppet::Type.newtype(:openldap_database) do
  @doc = "Manages OpenLDAP BDB and HDB databases."

  # Should it be ensurable as as of OpenLDAP 2.4.31 you cannot delete a Database
  # entry.
  ensurable

  newparam(:name) do
    desc "The default namevar."
  end

  newparam(:index) do
    desc "The index of the database."
    isnamevar
  end

  newparam(:backend) do
    desc "The name of the backend."
    isnamevar
    newvalues('bdb', 'hdb')
    defaultto('hdb')
  end

  def self.title_patterns
    [
      [
        /^({(\d+)}(bdb|hdb))$/,
	[
          [ :name, lambda{|x| x} ],
          [ :index, lambda{|x| x} ],
          [ :backend, lambda{|x| x} ],
	],
      ],
      [
        /(.*)/,
        [
           [ :name, lambda{|x| x} ],
        ],
      ],
    ]
  end

  newproperty(:directory) do
  end

  newproperty(:rootdn) do
  end

  newproperty(:rootpw) do
  end

  newproperty(:suffix) do
  end

end
