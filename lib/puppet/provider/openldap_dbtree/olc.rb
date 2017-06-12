require 'tempfile'

Puppet::Type.type(:openldap_cluster_dbtree).provide(:olc) do
  defaultfor :operatingsystem => :debian

  # Provider commands
  commands :ldapsearch => 'ldapsearch', :ldapadd => 'ldapadd'

  mk_resource_methods

  def self.instances
    instances = []
    suffixes  = []

    # Get all databases
    databases = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', 'cn=config', '-H', 'ldapi:///', "(olcDbNoSync=*)").split("\n\n")

    # Extract every database suffix
    databases.each do |block|
      db_attrs = block.gsub("\n ", "").split("\n")
      db_attrs.each do |line|
        if line =~ /^olcSuffix: /
          suffix = line.split(' ')[1]
          suffixes << suffix
        end
      end
    end

    # Get trees for every suffix
    suffixes.each do |suffix|

      # Parent database trees
      trees = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', suffix, '-H', 'ldapi:///', "(objectClass=organizationalUnit)").split("\n\n")
      trees.each do |block|
        block.gsub("\n ", "").split("\n").each do |line|

          # Get the tree DN
          if line =~ /^dn: /
            dn = line.split(": ")[1]
            tree = dn.match(/^ou=([^,]*),.*$/i).captures[0]

            # New instance
            instances << new(
              :tree => tree,
              :ensure => :present,
              :suffix => suffix,
            )
          end
        end
      end
    end
    instances
  end

  def self.prefetch(resources)
    trees = instances
    resources.keys.each do |name|
      if provider = trees.find{ |tree| tree.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create

    # Tree LDIF
    t  = Tempfile.new("ldap_dbtree")

    # Generate the tree LDIF
    t << "dn: ou=#{resource[:tree]},#{resource[:suffix]}\n"
    t << "objectClass: organizationalUnit\n"
    t << "ou: #{resource[:tree]}\n"
    t.close()

    # Create the database tree
    ldapadd('-c', '-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
