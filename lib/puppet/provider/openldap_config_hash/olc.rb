require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_config_hash).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    ldif = slapcat('(objectClass=olcGlobal)')

    entries = get_lines(ldif)

    resources = entries.reduce([]) do |tuples, entry|
      # Return at most two items from split, otherwise value might end up being
      # an array if the value holds e.g. a schema definition and has ": " in it.
      tuples << entry.split(': ', 2)
      tuples
    end

    resources.collect do |name, value|
      new(
        :name   => name,
        :value  => value,
        :ensure => :present
      )
    end
  end

  def self.prefetch(resources)
    items = instances
    resources.keys.each do |name|
      if provider = items.find{ |item| item.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    if !resource.nil? && resource[:value].is_a?(Hash)
      (resource[:value].keys - self.class.instances.map { |item| item.name }).empty?
    else
      @property_hash[:ensure] == :present
    end
  end

  def create
    ldif = temp_ldif()
    ldif << cn_config()
    ldif << changetype('modify')

    if resource[:value].is_a? Hash
      ldif << resource[:value].collect do |k, v|
        [add_or_replace_key(k), key_value(k, v)].join
      end.join(delimit)
      ldif << delimit
    else
      ldif << add_or_replace_key(resource[:name])
      ldif << key_value(resource[:name], resource[:value])
    end

    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end

    @property_hash[:ensure] = :present

    ldif_content
  end

  def destroy
    ldif = temp_ldif()
    ldif << cn_config()
    ldif << changetype('modify')

    if resource[:value].is_a? Hash
      ldif << resource[:value].keys.collect { |key| delete(key) }.join(delimit())
      ldif << delimit()
    else
      ldif << delete(name)
    end

    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end

    @property_hash.clear

    ldif_content
  end

  def value
    if resource[:value].is_a? Hash
      instances = self.class.instances
      values = resource[:value].map do |k, v|
        [ k, instances.find { |item| item.name == k }.get(:value) ]
      end
      Hash[values]
    else
      @property_hash[:value]
    end
  end

  def value=(value)
    ldif = temp_ldif()
    ldif << cn_config()
    ldif << changetype('modify')

    if resource[:value].is_a? Hash
      resource[:value].each do |k, v|
        ldif << replace_key(k)
        ldif << key_value(k, v)
        ldif << delimit()
      end
    else
        ldif << replace_key(name)
        ldif << key_value(name, value)
    end

    ldif.close

    Puppet.debug(IO.read(ldif.path))

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read(ldif.path)}\nError message: #{e.message}"
    end

    @property_hash[:value] = value
  end
end
