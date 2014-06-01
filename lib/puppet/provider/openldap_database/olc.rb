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
      'ldap:///???(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)))'
    )
    databases.split("\n\n").collect do |paragraph|
      suffix = nil
      index = nil
      backend = nil
      directory = nil
      rootdn = nil
      rootpw = nil
      suffix = nil
      paragraph.split("\n").collect do |line|
        case line
        when /^olcDatabase: /
          index, backend = line.match(/^olcDatabase: \{(\d+)\}(bdb|hdb)$/).captures
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

    `service slapd stop`
    File.delete("#{default_confdir}/cn=config/olcDatabase={#{@property_hash[:index]}}#{resource[:backend]}.ldif")
    slapcat(
      '-b',
      'cn=config',
      '-H',
      "ldap:///???(objectClass=olc#{resource[:backend].to_s.capitalize}Config)"
    ).split("\n").select { |line| line =~ /^dn: / }.select { |dn| dn.match(/^dn: olcDatabase={(\d+)}#{resource[:backend]},cn=config$/).captures[0].to_i > @property_hash[:index] }.each { |dn|
      index = dn[/\d+/].to_i
      old_filename = "#{default_confdir}/cn=config/olcDatabase={#{index}}#{resource[:backend]}.ldif"
      new_filename = "#{default_confdir}/cn=config/olcDatabase={#{index - 1}}#{resource[:backend]}.ldif"
      File.rename(old_filename, new_filename)
      text = File.read(new_filename)
      replace = text.gsub!("{#{index}}#{resource[:backend]}", "{#{index - 1}}#{resource[:backend]}")
      File.open(new_filename, "w") { |file| file.puts replace }
    }
    `service slapd start`
    @property_hash.clear
  end

  def create
    t = Tempfile.new('openldap_database')
    if resource[:index]
      t << "dn: olcDatabase={#{resource[:index]}}#{resource[:backend]},cn=config\n"
      t << "changetype: modify\n"
      t << "replace: olcDbDirectory\nolcDbDirectory: #{resource[:directory]}\n" if resource[:directory]
      t << "replace: olcRootDN\nolcRootDN: #{resource[:rootdn]}\n" if resource[:rootdn]
      t << "replace: olcRootPW\nolcRootPW: #{resource[:rootpw]}\n" if resource[:rootpw]
      t << "replace: olcSuffix\nolcSuffix: #{resource[:suffix]}\n" if resource[:suffix]
    else
      t << "dn: olcDatabase=#{resource[:backend]},cn=config\n"
      t << "changetype: add\n"
      t << "objectClass: olcDatabaseConfig\n"
      t << "objectClass: olc#{resource[:backend].to_s.capitalize}Config\n"
      t << "olcDatabase: #{resource[:backend]}\n"
      t << "olcDbDirectory: #{resource[:directory]}\n" if resource[:directory]
      t << "olcRootDN: #{resource[:rootdn]}\n" if resource[:rootdn]
      t << "olcRootPW: #{resource[:rootpw]}\n" if resource[:rootpw]
      t << "olcSuffix: #{resource[:suffix]}\n" if resource[:suffix]
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
    if resource[:index]
      @property_hash[:index] = resource[:index]
    else
      slapcat(
        '-b',
        'cn=config',
        '-H',
        "ldap:///???(&(objectClass=olc#{resource[:backend].to_s.capitalize}Config)(olcSuffix=#{resource[:suffix]}))").split("\n").collect do |line|
        if line =~ /^olcDatabase: /
          index = line.match(/^olcDatabase: {(\d+)}#{resource[:backend]}$/).captures[0]
          @property_hash[:index] = index
        end
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
      t << "replace: olcDbDirectory\nolcDbDirectory: #{resource[:directory]}\n" if @property_flush[:directory]
      t << "replace: olcRootDN\nolcRootDN: #{resource[:rootdn]}\n" if @property_flush[:rootdn]
      t << "replace: olcRootPW\nolcRootPW: #{resource[:rootpw]}\n" if @property_flush[:rootpw]
      t << "replace: olcSuffix\nolcSuffix: #{resource[:suffix]}\n" if @property_flush[:suffix]
      t.close
      Puppet.debug(IO.read t.path)
      begin
        ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
      rescue Exception => e
        raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

end
