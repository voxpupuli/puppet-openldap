require 'base64'
require 'tempfile'

Puppet::Type.type(:openldap_database).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    databases = slapcat(
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)(objectClass=olcMdbConfig)))'
    )
    databases.split("\n\n").collect do |paragraph|
      suffix = nil
      index = nil
      backend = nil
      directory = nil
      rootdn = nil
      rootpw = nil
      paragraph.gsub("\n ", "").split("\n").collect do |line|
        case line
        when /^olcDatabase: /
          index, backend = line.match(/^olcDatabase: \{(\d+)\}(bdb|hdb|mdb)$/).captures
        when /^olcDbDirectory: /
          directory = line.split(' ')[1]
        when /^olcRootDN: /
          rootdn = line.split(' ')[1]
        when /^olcRootPW:: /
          rootpw = Base64.decode64(line.split(' ')[1])
        when /^olcSuffix: /
          suffix = line.split(' ')[1]
        end
      end
      new(
        :ensure    => :present,
        :name      => suffix,
        :suffix    => suffix,
        :index     => index.to_i,
        :backend   => backend,
        :directory => directory,
        :rootdn    => rootdn,
        :rootpw    => rootpw
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

  def destroy
    default_confdir = Facter.value(:osfamily) == 'Debian' ? '/etc/ldap/slapd.d' : Facter.value(:osfamily) == 'RedHat' ? '/etc/openldap/slapd.d' : nil
    backend = @property_hash[:backend]

    `service slapd stop`
    File.delete("#{default_confdir}/cn=config/olcDatabase={#{@property_hash[:index]}}#{backend}.ldif")
    slapcat(
      '-b',
      'cn=config',
      '-H',
      "ldap:///???(objectClass=olc#{backend.to_s.capitalize}Config)"
    ).split("\n").select { |line| line =~ /^dn: / }.select { |dn| dn.match(/^dn: olcDatabase={(\d+)}#{backend},cn=config$/).captures[0].to_i > @property_hash[:index] }.each { |dn|
      index = dn[/\d+/].to_i
      old_filename = "#{default_confdir}/cn=config/olcDatabase={#{index}}#{backend}.ldif"
      new_filename = "#{default_confdir}/cn=config/olcDatabase={#{index - 1}}#{backend}.ldif"
      File.rename(old_filename, new_filename)
      text = File.read(new_filename)
      replace = text.gsub!("{#{index}}#{backend}", "{#{index - 1}}#{backend}")
      File.open(new_filename, "w") { |file| file.puts replace }
    }
    `service slapd start`
    @property_hash.clear
  end

  def initdb
    t = Tempfile.new('openldap_database')
    t << "dn: #{resource[:suffix]}\n"
    t << "changetype: add\n"
    t << "objectClass: top\n"
    t << "objectClass: dcObject\n"
    t << "objectClass: organization\n"
    t << "dc: #{resource[:suffix].split(/,?dc=/).delete_if { |c| c.empty? }[0]}\n"
    t << "o: #{resource[:suffix].split(/,?dc=/).delete_if { |c| c.empty? }.join('.')}\n"
    t << "\n"
    t << "dn: cn=admin,#{resource[:suffix]}\n"
    t << "objectClass: simpleSecurityObject\n" if resource[:rootpw]
    t << "objectClass: organizationalRole\n"
    t << "cn: admin\n"
    t << "description: LDAP administrator\n"
    t << "userPassword: #{resource[:rootpw]}\n" if resource[:rootpw]
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    t.delete
  end

  def create
    t = Tempfile.new('openldap_database')
    t << "dn: olcDatabase=#{resource[:backend]},cn=config\n"
    t << "changetype: add\n"
    t << "objectClass: olcDatabaseConfig\n"
    t << "objectClass: olc#{resource[:backend].to_s.capitalize}Config\n"
    t << "olcDatabase: #{resource[:backend]}\n"
    t << "olcDbDirectory: #{resource[:directory]}\n" if resource[:directory]
    t << "olcRootDN: #{resource[:rootdn]}\n" if resource[:rootdn]
    t << "olcRootPW: #{resource[:rootpw]}\n" if resource[:rootpw]
    t << "olcSuffix: #{resource[:suffix]}\n" if resource[:suffix]
    t << "olcDbIndex: objectClass eq\n"
    t << "olcAccess: to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break\n"
    t << "olcAccess: to attrs=userPassword\n"
    t << "  by self write\n"
    t << "  by anonymous auth\n"
    t << "  by dn=\"cn=admin,#{resource[:suffix]}\" write\n"
    t << "  by * none\n"
    t << "olcAccess: to dn.base=\"\" by * read\n"
    t << "olcAccess: to *\n"
    t << "  by self write\n"
    t << "  by dn=\"cn=admin,#{resource[:suffix]}\" write\n"
    t << "  by * read\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    t.delete
    initdb
    @property_hash[:ensure] = :present
    slapcat(
      '-b',
      'cn=config',
      '-H',
      "ldap:///???(&(objectClass=olc#{resource[:backend].to_s.capitalize}Config)(olcSuffix=#{resource[:suffix]}))").split("\n").collect do |line|
      if line =~ /^olcDatabase: /
        @property_hash[:index] = line.match(/^olcDatabase: \{(\d+)\}#{resource[:backend]}$/).captures[0]
      end
    end
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
    if not @property_flush.empty?
      t = Tempfile.new('openldap_database')
      t << "dn: olcDatabase={#{@property_hash[:index]}}#{resource[:backend]},cn=config\n"
      t << "changetype: modify\n"
      t << "replace: olcDbDirectory\nolcDbDirectory: #{resource[:directory]}\n-\n" if @property_flush[:directory]
      t << "replace: olcRootDN\nolcRootDN: #{resource[:rootdn]}\n-\n" if @property_flush[:rootdn]
      t << "replace: olcRootPW\nolcRootPW: #{resource[:rootpw]}\n-\n" if @property_flush[:rootpw]
      t << "replace: olcSuffix\nolcSuffix: #{resource[:suffix]}\n-\n" if @property_flush[:suffix]
      t.close
      Puppet.debug(IO.read t.path)
      begin
        ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
      rescue Exception => e
        raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
      end
      initdb if @property_flush[:directory]
    end
    @property_hash = resource.to_hash
  end

end
