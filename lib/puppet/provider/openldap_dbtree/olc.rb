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

      # Subdomain trees
      subdomains = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', suffix, '-H', 'ldapi:///', "(description=subdomain)").split("\n\n")
      subdomains.each do |block|
        block.gsub("\n ", "").split("\n").each do |line|

          # Get the subdomain
          if line =~ /^dc: /
            subdomain = line.split(": ")[1]
            subsuffix = "dc=#{subdomain},#{suffix}"

            # Subtrees
            subtrees = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', subsuffix, '-H', 'ldapi:///', "(objectClass=organizationalUnit)").split("\n\n")
            subtrees.each do |tree|
              tree.gsub("\n ", "").split("\n").each do |tree_line|

                # Get the tree DN
                if tree_line =~ /^dn: /
                  dn = tree_line.split(": ")[1]
                  subtree = dn.match(/^ou=([^,]*),.*$/i).captures[0]

                  # New instance
                  instances << new(
                    :name => "#{subsuffix} #{subtree}",
                    :ensure => :present,
                    :suffix => subsuffix,
                    :tree => subtree
                  )
                end
              end
            end
          end
        end
      end

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
              :name => "#{suffix} #{tree}",
              :ensure => :present,
              :suffix => suffix,
              :tree => tree
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
