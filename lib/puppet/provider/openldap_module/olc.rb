require 'tempfile'

Puppet::Type.type(:openldap_module).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    i = []
    slapcat(
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(objectClass=olcModuleList)'
    ).split("\n\n").collect do |paragraph|
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
    puts 'In openldap_module create'
    t = Tempfile.new('openldap_module')
    t << "dn: cn=module{0},cn=config\n"
    t << "add: olcModuleLoad\n"
    t << "olcModuleLoad: #{resource[:name]}.la\n"
    t.close
    puts IO.read t.path
    ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    @property_hash[:ensure] = :present
  end

end
