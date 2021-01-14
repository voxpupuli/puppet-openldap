require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type
  .type(:openldap_global_conf)
  .provide(:olc, parent: Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => [:debian, :freebsd, :redhat, :suse]

  mk_resource_methods

  def self.instances
    items = slapcat('(objectClass=olcGlobal)')
    options = {}

    # iterate olc options and removes any keys when it found any duplications
    # such as olcServerID
    items.gsub("\n ", '').split("\n").select { |e| e =~ /^olc/ }.collect do |line|
      name, value = line.split(': ')
      name = name[3, name.length]
      if options[name] && !options[name].is_a?(Array)
        options[name] = [options[name]]
        options[name].push(value)
      elsif options[name]
        options[name].push(value)
      else
        options[name] = value
      end
    end
    new_instances = []

    # iterate options and creates new ProviderOlc instances
    options.each do |k, v|
      new_instances << Puppet::Type::Openldap_global_conf::ProviderOlc.new(
        name: k,
        ensure: :present,
        value: v
      )
    end

    new_instances
  end

  def self.prefetch(resources)
    items = instances
    resources.keys.each do |name|
      provider = items.find { |item| item.name.casecmp(name.downcase).zero? }
      resources[name].provider = provider if provider
    end
  end

  def exists?
    if resource[:value].is_a? Hash
      (resource[:value].keys - self.class.instances.map(&:name)).length < resource[:value].keys.length
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
        if v.is_a? Array
          v.each { |x| t << "olc#{k}: #{x}\n" }
        else
          t << "olc#{k}: #{v}\n"
        end
        t << "-\n"
      end
    else
      t << "add: olc#{resource[:name]}\n"
      t << "olc#{resource[:name]}: #{resource[:value]}\n"
    end
    t.close
    Puppet.debug(IO.read(t.path))
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
    Puppet.debug(IO.read(t.path))
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
      values = resource[:value].map do |k, _v|
        found = instances.find { |item| item.name == k }
        [k, found.nil? ? nil : found.get(:value)]
      end.reject { |v| v[1].nil? }
      Hash[values]
    else
      @property_hash[:value]
    end
  end

  def value=(value)
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    instances = self.class.instances
    if resource[:value].is_a? Hash
      resource[:value].each do |k, v|
        found = instances.find { |item| item.name == k }
        next if found && v == found.get(:value)
        t << if found
               "replace: olc#{k}\n"
             else
               "add: olc#{k}\n"
             end
        if v.is_a? Array
          v.each { |x| t << "olc#{k}: #{x}\n" }
        else
          t << "olc#{k}: #{v}\n"
        end
        t << "-\n"
      end
    else
      found = instances.find { |item| item.name == name }
      t << if found
             "replace: olc#{name}\n"
           else
             "add: olc#{name}\n"
           end
      t << "olc#{name}: #{value}\n"
    end
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:value] = value
  end
end
