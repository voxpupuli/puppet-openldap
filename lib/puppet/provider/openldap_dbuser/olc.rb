require 'tempfile'

Puppet::Type.type(:openldap_dbuser).provide(:olc) do
  defaultfor :osfamily => :debian, :osfamily => :redhat

  # Provider commands
  commands :ldapsearch => 'ldapsearch', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    instances = []
    suffixes  = []

    # Get all databases
    databases = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', 'cn=config', '-H', 'ldapi:///', "(olcDbDirectory=*)").split("\n\n")

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

    # Current user container
    user = ''

    # Look for system user account
    suffixes.each do |suffix|

      # Database users
      users = ldapsearch('-Q', '-LLL', '-Y', 'EXTERNAL', '-b', suffix, '-H', 'ldapi:///', "(description=user)").split("\n\n")
      users.each do |block|
        block.gsub("\n ", "").split("\n").each do |line|

          # Get the user name
          if line =~ /^cn: /
            user = line.split(": ")[1]
          end

          # Get the user password
          if line =~ /^userPassword:: /
            passwd = line.split(":: ")[1]

            # New instance
            instances << new(
              :ensure => :present,
              :name   => "#{suffix} #{user}",
              :suffix => suffix,
              :user   => user,
              :passwd => passwd
            )
          end
        end
      end
    end
    instances
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find{ |user| user.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    user = "cn=#{resource[:user]},#{resource[:suffix]}"

    # Password LDIF / hash
    t  = Tempfile.new("ldap_dbuser")

    # Generate the attribute LDIF
    t << "dn: #{user}\n"
    t << "changetype: add\n"
    t << "objectClass: top\n"
    t << "objectClass: organizationalRole\n"
    t << "objectClass: simpleSecurityObject\n"
    t << "cn: #{resource[:user]}\n"
    t << "userPassword: #{resource[:passwd]}\n"
    t << "description: user\n"
    t.close()

    # Run the password LDIF
    ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
