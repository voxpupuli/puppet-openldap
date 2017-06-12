require 'time'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_schema).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => [:debian, :redhat]

  mk_resource_methods

  def self.instances
    schemas = []
    slapcat('(objectClass=olcSchemaConfig)').split("\n\n").each do |paragraph|
      schema = { 'name' => nil, 'index' => nil, 'date' => nil }
      paragraph.split("\n").each do |line|
        case line
        when /^cn: \{(\d+)\}(\S+)/
          schema['name'] = "#{$2}"
          schema['index'] = "#{$1}"
        when /^modifyTimestamp: (\S+)/
          schema['date'] = Time.strptime("#{$1}", '%Y%m%d%H%M%S%Z')
        end
      end

      if not schema['name'].nil?
        schemas.push(schema)
      end
    end
    schemas.map { |schema|
      new(
        :ensure => :present,
        :index  => schema['index'],
        :name   => schema['name'],
        :date   => schema['date']
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

  def self.schemaToLdifReplace(schema, name)
    ldif = [
      "dn: cn=#{name},cn=schema,cn=config",
      "changetype: modify",
    ]
    objId = []
    attrType = []
    objClass = []

    current = nil

    schema.split("\n").each do |line|
      case line
      when /^\s*#/
        next
      when /^$/
        next
      when /^objectidentifier(.*)$/i
        current = objId
        current.push("olcObjectIdentifier:#{$1}")
      when /^attributetype(.*)$/i
        current = attrType
        current.push("olcAttributeTypes:#{$1}")
      when /^objectclass(.*)$/i
        current = objClass
        current.push("olcObjectClasses:#{$1}")
      when /^\s+(.*)/
        if not current.nil?
          current.last << " #{$1}"
        end
      end
    end

    if objId.length > 0
      ldif.push('replace: olcObjectIdentifier')
      ldif.push(*objId)
      ldif.push('-')
    end

    ldif.push('replace: olcAttributeTypes')
    ldif.push(*attrType)
    ldif.push('-')

    ldif.push('replace: olcObjectClasses')
    ldif.push(*objClass)
    ldif.push('-')

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
        if @property_hash[:ensure] == :present
          t << self.class.schemaToLdifReplace(schema, "{#{@property_hash[:index]}}#{@property_hash[:name]}")
        else
          t << self.class.schemaToLdif(schema, resource[:name])
        end
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
    timeshift = File.mtime(resource[:path]) - @property_hash[:date]
    @property_hash[:ensure] == :present and timeshift <= 0
  end

  def destroy
    raise Puppet::Error, "Removing schemas is not supported by this provider. Slapd needs to be stopped and the schema must be removed manually."
  end
end
