require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_module).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.create_module_list
    ldif = temp_ldif('openldap_module')
    ldif << "dn: cn=module{0},cn=config\n"
    ldif << "changetype: add\n"
    ldif << "cn: module\n"
    ldif << "objectclass: olcModuleList\n"

    ldif.close

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif}\nError message: #{e.message}"
    end
  end

  def self.instances
    dn = slapcat('(objectClass=olcModuleList)')
    create_module_list() if dn.empty?

    i = []

    dn.split("\n\n").collect do |paragraph|
      name = nil
      paragraph.split("\n").collect do |line|
        case line
        when /^olcModuleLoad: /
          i << new(
            :ensure => :present,
            :name   => line.match(/^olcModuleLoad: \{\d+\}([^\.]+).*$/).captures[0]
          )
	end
      end
    end
    i
  end

  def self.prefetch(resources)
    mods = instances
    resources.keys.each do |name|
      if provider = mods.find{ |mod| mod.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    t = Tempfile.new('openldap_module')
    t << "dn: cn=module{0},cn=config\n"
    t << "add: olcModuleLoad\n"
    t << "olcModuleLoad: #{resource[:name]}.la\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

end
