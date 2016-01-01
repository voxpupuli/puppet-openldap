require 'tempfile'

Puppet::Type.type(:openldap_module).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    # Create dn: cn=Module{0},cn=config if not exists
    dn = slapcat('-b', 'cn=config', '-H', 'ldap:///???(objectClass=olcModuleList)')
    if dn == ''
      ldif = %Q{dn: cn=module{0},cn=config
changetype: add
cn: module
objectclass: olcModuleList
}
      begin
        execute(%Q{echo -n "#{ldif}" | ldapmodify -Y EXTERNAL -H ldapi:///})
      rescue Exception => e
        raise Puppet::Error, "LDIF content:\n#{ldif}\nError message: #{e.message}"
      end
    end
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
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

end
