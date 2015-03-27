require 'tempfile'

Puppet::Type.type(:openldap_schema).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapadd => 'ldapadd', :slaptest => 'slaptest', :ldapsearch => 'ldapsearch'

  mk_resource_methods

  @@openldap_schema_existing = []
  @@openldap_schema_new = []
  @@openldap_schema_create_count = 0
  @@openldap_schema_max_count = 0

  def self.instances
    self.getSchemaNames.map { |schema|
          new(
            :ensure => :present,
            :name   => schema
          )
    }
  end

  def self.getSchemaNames
      schemas = []
      ldapsearch('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-b', 'cn=config', '(objectClass=olcSchemaConfig)', 'cn').split("\n\n").each do |paragraph|
          paragraph.split("\n").each do |line|
              if line =~ /^cn: \{/
                  schemas.push line
              end
          end
      end
      schemas.map{ |entry| entry.match(/^cn: \{\d+\}(\S+)/)[1] }
  end

  def self.prefetch(resources)
    # Match installed schemas with requested schemas to find the paths to them
    installed = getSchemaNames()
    for schema in installed do
        if match = resources.values.find{ |resource| resource.pathWithDefault =~ /#{Regexp.escape(schema)}\.schema$/ }
            @@openldap_schema_existing.push(match)
        else
            warning("Missing schema '#{schema}', might cause insertion issues")
        end
    end

    mods = instances
    
    resources.keys.each do |name|
      if provider = mods.find{ |mod| mod.name == name }
        resources[name].provider = provider
      else
        @@openldap_schema_max_count += 1
      end
    end
  end

  def create
    # Order new resources by priority
    @@openldap_schema_new.push(resource)

    # Only insert in the last requested resource
    @@openldap_schema_create_count += 1
    puts @@openldap_schema_max_count
    unless @@openldap_schema_create_count == @@openldap_schema_max_count
        return
    end

    t = Tempfile.new('openldap_schemas_ldif')
    t2 = Tempfile.new('openldap_schemas_includes')
    
    for resource in @@openldap_schema_existing do
        t2 << "include #{resource.pathWithDefault}\n"
    end
    for resource in @@openldap_schema_new do
        t2 << "include #{resource.pathWithDefault}\n"
    end

    t2.close

    begin
      Dir.mktmpdir{|ldif_dir|
        slaptest('-f', t2.path, '-F', ldif_dir)
        ldif = slapcat('-n0', '-F', ldif_dir).split("\n\n")

        filtered = []
        
        ldif = ldif.each do |paragraph|
            # Make sure we don't add other configuration files other than the schemas or we lose acls
            description = paragraph.split("\n")[0]
            if match = description.match(/^dn: cn=\{\d+\}([^,]+),cn=schema,cn=config/)
                name = match[1]
                unless @@openldap_schema_new.any?{ |resource| resource.name == name }
                    next
                end
                paragraph.split("\n").each do |line|
                    # Convert between slapcat and ldapadd (slapadd needs a stopped slapd)
                    unless line =~ /^(creatorsName|createTimestamp|modifiersName|modifyTimestamp|structuralObjectClass|entryUUID|entryCSN): /
                        filtered.push(line)
                    end
                end
                filtered.push("")
            end
        end
        filtered = filtered.join("\n")
        t.write filtered
        t.close
      }

      ldapadd('-cQY', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "Config: #{IO.read t2.path}\n LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
