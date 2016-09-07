require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_global_conf).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    items = slapcat('(objectClass=olcGlobal)')
    items.gsub("\n ", "").split("\n").select{|e| e =~ /^olc/}.collect do |line|
      name, value = line.split(': ')
      # initialize @property_hash
      new(
        :name   => name[3, name.length],
        :ensure => :present,
        :value  => value
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
    if resource[:value].is_a? Hash
      (resource[:value].keys - self.class.instances.map { |item| item.name }).empty?
    else
      @property_hash[:ensure] == :present
    end
  end

  def create
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    if resource[:value].is_a? Hash
      resource[:value].each do |k, v|
        t << "add: olc#{k}\n"
        t << "olc#{k}: #{v}\n"
        t << "-\n"
      end
    else
      t << "add: olc#{resource[:name]}\n"
      t << "olc#{resource[:name]}: #{resource[:value]}\n"
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    if resource[:value].is_a? Hash
      resource[:value].keys.each do |k|
        t << "delete: olc#{k}\n"
        t << "-\n"
      end
    else
      t << "delete: olc#{name}\n"
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash.clear
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
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    if resource[:value].is_a? Hash
      resource[:value].each do |k, v|
        t << "replace: olc#{k}\n"
        t << "olc#{k}: #{v}\n"
        t << "-\n"
      end
    else
      t << "replace: olc#{name}\n"
      t << "olc#{name}: #{value}\n"
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:value] = value
  end

end
