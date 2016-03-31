require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. puppet_x openldap pw_hash.rb]))

Puppet::Type.
  type(:openldap_config_entry).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  desc <<-EOS
  olc provider for slapd configuration. Uses slapcat and ldapmodify to change
  configuration.

  Note: This provider can only be used for non-critical changes to the config
  database. It will in the future provide a white- or blacklist to ensure
  this. Use openldap_config for TLS, directories, etc.

  EOS

  mk_resource_methods

  def self.instances
    entries = get_lines(slapcat('(objectClass=olcGlobal)'))

    resources = entries.reduce([]) do |tuples, entry|
      # Return at most two items from split, otherwise value might end up being
      # an array if the value holds e.g. a schema definition and has ": " in it.
      tuples << entry.split(': ', 2)
      tuples
    end

    resources.collect do |key, value|
      name = "#{key}-#{Puppet::Puppet_X::Openldap::PwHash.hash_string(value, 'openldap_config_entry')}"

      new(
        # XXX: Is setting the name param here necessary or even
        #      possible/feasable?
        :name   => name,
        :ensure => :present,
        :key    => key,
        :value  => value
      )
    end
  end

  def self.prefetch(resources)
    items = instances
    resources.keys.each do |name|
      if provider = items.find { |item| item.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    ldif = temp_ldif()

    ldif << cn_config()
    ldif << changetype('modify')
    ldif << add_or_replace_key(resource[:key], resource[:replace])
    ldif << key_value(resource[:key], resource[:value])
    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error,
        "LDIF content:\n#{IO.read(ldif.path)}\n\nError message: #{e.message}\n\nBacktrace:#{e.backtrace}\n"
    end

    @property_hash[:ensure] = :present

    ldif_content
  end

  def add_or_replace_manual
    return replace_key(resource[:key]) if resource[:replace] == :true
    return add(resource[:key])
  end

  def destroy
    ldif = temp_ldif()
    ldif << cn_config()
    ldif << del(resource[:key])
    ldif.close

    Puppet.debug(IO.read(ldif.path))

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error,
        "LDIF content:\n#{IO.read(ldif.path)}\n\nError message: #{e.message}\n\nBacktrace:#{e.backtrace}\n"
    end

    @property_hash.clear
  end

  def key=(new_key)
    fail("key is a readonly property and cannot be changed.")
  end

  def value=(new_value)
    fail("value is a readonly property and cannot be changed.")
  end
end
