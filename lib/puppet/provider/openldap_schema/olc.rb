require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_schema).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    schemas = []
    slapcat('(objectClass=olcSchemaConfig)').split("\n\n").each do |paragraph|
      paragraph.split("\n").each do |line|
        if line =~ /^cn: \{/
          schemas.push line
        end
      end
    end
    names = schemas.map{ |entry| entry.match(/^cn: \{\d+\}(\S+)/)[1] }
    names.map { |schema|
      new(
        :ensure => :present,
        :name		=> schema
      )
    }
  end

  def self.schemaToLdif(schema, name)
    ldif = [
      "dn: cn=#{name},cn=schema,cn=config",
      "objectClass: olcSchemaConfig",
      "cn: #{name}",
    ]
    schema.split("\n").each do |line|
      case line
      when /^\s*#/    # Comments are ok
        ldif.push(line)
      when /^$/   # Replace empty lines with comment
        ldif.push("#")
      when /^objectidentifier(.*)$/i    # Rewrite tags
        ldif.push("olcObjectIdentifier:#{$1}")
      when /^attributetype(.*)$/i
        ldif.push("olcAttributeTypes:#{$1}")
      when /^objectclass(.*)$/i
        ldif.push("olcObjectClasses:#{$1}")
      when /^\s+(.*)/   # Rewrite continuation whitespace
        ldif.push("  #{$1}")    # One space to indicate continuation, plus one for spacing between words
      end
    end
    ldif.join("\n")
  end

  def self.prefetch(resources)
    existing = instances
    resources.keys.each do |name|
      if provider = existing.find { |r| r.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create

    t = Tempfile.new('openldap_schemas_ldif')

    begin
      schema = IO.read resource[:path]
      file_extention = File.extname resource[:path]
      if file_extention == '.schema'
        t << self.class.schemaToLdif(schema, resource[:name])
      else
        t << schema
      end
      t.close
      ldapadd(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    raise Puppet::Error, "Removing schemas is not supported by this provider. Slapd needs to be stopped and the schema must be removed manually."
  end
end
