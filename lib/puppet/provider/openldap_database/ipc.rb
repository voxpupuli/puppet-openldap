require 'tempfile'

Puppet::Type.type(:openldap_database).provide(:ipc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  # TODO: confine to and default for OpenLDAP >= 2.3

  commands :ldapsearch => `which ldapsearch`.chomp,
           :ldapmodify => `which ldapmodify`.chomp

  mk_resource_methods

  def self.instances
    databases = ldapsearch('-LLL', '-Y', 'EXTERNAL', '-H', 'ldapi:///', '-b', 'cn=config', '(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)))')
    databases.split("\n\n").collect do |paragraph|
      name = nil
      index = nil
      backend = nil
      directory = nil
      rootdn = nil
      rootpw = nil
      suffix = nil
      paragraph.split("\n").collect do |line|
        case line
        when /^olcDatabase: /
          name = line.split(' ')[1]
	  index, backend = line.match(/^olcDatabase: {(\d+)}(bdb|hdb)$/).captures
        when /^olcDbDirectory: /
          directory = line.split(' ')[1]
        when /^olcRootDN: /
          rootdn = line.split(' ')[1]
        when /^olcRootPW: /
          rootpw = line.split(' ')[1]
        when /^olcSuffix: /
          suffix = line.split(' ')[1]
        end
      end
      new(
        :name      => name,
        :index     => index.to_i,
        :backend   => backend,
        :ensure    => :present,
        :directory => directory,
        :rootdn    => rootdn,
        :rootpw    => rootpw,
        :suffix    => suffix,
      )
    end
  end

  def self.prefetch(resources)
    databases = instances
    resources.keys.each do |name|
      if provider = databases.find{ |database| database.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    t = Tempfile.new('openldap_database')
    t << "dn: olcDatabase={#{resource[:index]}}#{resource[:backend]},cn=config\n"
    t << "objectClass: olc#{resource[:backend].capitalize}Config\n"
    t << "olcDatabase: {#{resource[:index]}}#{resource[:backend]}\n"
    t << "olcDbDirectory: #{resource[:directory]}\n" if resource[:directory]
    t << "olcSuffix: #{resource[:suffix]}\n" if resource[:suffix]
    t.close
    ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    @property_hash[:ensure] = :present
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def directory=(value)
    @property_flush[:directory] = value
  end

  def rootdn=(value)
    @property_flush[:rootdn] = value
  end

  def rootpw=(value)
    @property_flush[:rootpw] = value
  end

  def suffix=(value)
    @property_flush[:suffix] = value
  end

  def flush
    if @property_flush
      t = Tempfile.new('openldap_database')
      t << "dn: olcDatabase={#{resource[:index]}}#{resource[:backend]},cn=config\n"
      t << "replace: olcDbDirectory\nolcDbDirectory: #{resource[:directory]}\n" if @property_flush[:directory]
      t << "replace: olcRootDN\nolcRootDN: #{resource[:rootdn]}\n" if @property_flush[:rootdn]
      t << "replace olcRootPW\nolcRootPW: #{resource[:rootpw]}\n" if @property_flush[:rootpw]
      t << "replace olcSuffix\nolcSuffix: #{resource[:suffix]}\n" if @property_flush[:suffix]
      t.close
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    end
    @property_hash = resource.to_hash
  end

end
