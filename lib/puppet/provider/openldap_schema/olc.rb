require 'tempfile'

Puppet::Type.type(:openldap_schema).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify', :slaptest => 'slaptest'

  mk_resource_methods

  @@openldap_schema_paths = []

  def self.instances
    i = []
    slapcat(
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(objectClass=olcSchemaConfig)'
    ).split("\n\n").collect do |paragraph|
      name = nil
      paragraph.split("\n").collect do |line|
        case line
        when /^cn: /
          i << new(
            :ensure => :present,
            :name   => line.match(/^cn: (\{\d+\})?(.*)$/).captures[1]
          )
        end
      end
    end
    i
  end

  def self.prefetch(resources)
    mods = instances
    missing = false
	# we need to add all schemas again to add a single missing schema (can't compile with missing references)
    resources.keys.each do |name|
        unless provider = mods.find{ |mod| mod.name == name }
            missing = true
        end
    end

    unless missing
        resources.keys.each do |name|
          if provider = mods.find{ |mod| mod.name == name }
            resources[name].provider = provider
          end
        end
    end
  end

  def create
    if resource[:path]
      @@openldap_schema_paths.push(resource[:path])
    else
      @@openldap_schema_paths.push("/etc/ldap/schema/" + resource[:name] + ".schema")
    end

    t = Tempfile.new('openldap_schemas_ldif')
    t2 = Tempfile.new('openldap_schemas_includes')
    debug('next')
    for path in @@openldap_schema_paths
      t2 << "include #{path}\n"
    end
    t2.close

    begin
      Dir.mktmpdir{|ldif_dir|
        slaptest('-f', t2.path, '-F', ldif_dir)

        slapcat('-n0', '-F', ldif_dir) do |file|
          file.each_line{ |line| t << line }
        end
        t.close
      }

      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "Config: #{IO.read t2.path}\n LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end