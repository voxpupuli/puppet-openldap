require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

require 'base64'
require 'tempfile'

Puppet::Type.
  type(:openldap_database).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  defaultfor :osfamily => [:debian, :redhat]

  mk_resource_methods

  def self.instances
    databases = get_entries(slapcat("(|(olcDatabase=monitor)(olcDatabase={0}config)(&(objectClass=olcDatabaseConfig)(|(objectClass=olcBdbConfig)(objectClass=olcHdbConfig)(objectClass=olcMdbConfig)(objectClass=olcMonitorConfig))))"))

    databases.collect do |database|
      suffix          = nil
      index           = nil
      backend         = nil
      directory       = nil
      rootdn          = nil
      rootpw          = nil
      readonly        = nil
      sizelimit       = nil
      timelimit       = nil
      updateref       = nil
      dboptions       = {}
      mirrormode      = nil
      syncusesubentry = nil
      syncrepl        = nil
      limits          = []

      database.collect do |line|
        case line
        when /^olcDatabase: /
          index, backend = line.
            match(/^olcDatabase: \{(\d+)\}(bdb|hdb|mdb|monitor|config)$/).
            captures

        when /^olcDbDirectory: /
          directory = last_of_split(line)

        when /^olcRootDN: /
          rootdn = last_of_split(line)

        when /^olcRootPW:: /
          rootpw = Base64.decode64(last_of_split(line))

        when /^olcSuffix: /
          suffix = last_of_split(line)

        when /^olcReadOnly: /i
          readonly = last_of_split(line)

        when /^olcSizeLimit: /i
          sizelimit = last_of_split(line)

        when /^olcTimeLimit: /i
          timelimit = last_of_split(line)

        when /^olcUpdateref: /i
          updateref = last_of_split(line)

        when /^olcDb\S+: /i
          attribute, value = line.split(': ', 2)
          attribute.downcase!

          case attribute.to_sym
          when :olcdbnosync
            dboptions['dbnosync'] = value

          when :olcdbpasesize
            dboptions['dbpagesize'] = value

          when :olcdbconfig
            dboptions['dbconfig'] ||= []

	    if value =~ /^\{\d+\}.+$/
	      dboptions['dbconfig'].push value.
                match(/^\{\d+\}(.+)$/).
                captures.
                first
	    end

          else
            attribute_name = attribute.match(/^olcDb(\S+)$/i).captures.first

            dboptions[attribute_name] ||= []
            dboptions[attribute_name].push(value)
          end

        when /^olcMirrorMode: /
          mirrormode = last_of_split(line) == 'TRUE' ? :true : :false

        when /^olcSyncUseSubentry: /
          syncusesubentry = last_of_split(line)

        when /^olcSyncrepl: /
          syncrepl ||= []
          value = last_of_split(line)
          syncrepl.push(value.match(/^(\{\d+\})?(.+)$/).captures.last + "\n")

        when /^olcLimits: /
          limit = line.match(/^olcLimits:\s+(\{\d+\})?(.+)$/).captures.last
          limits << limit
        end
      end

      suffix ||= 'cn=monitor' if backend == 'monitor'
      suffix ||= 'cn=config'  if backend == 'config'

      new(
        :ensure          => :present,
        :name            => suffix,
        :suffix          => suffix,
        :index           => index.to_i,
        :backend         => backend,
        :directory       => directory,
        :rootdn          => rootdn,
        :rootpw          => rootpw,
        :readonly        => readonly,
        :sizelimit       => sizelimit,
        :timelimit       => timelimit,
        :updateref       => updateref,
        :dboptions       => dboptions,
        :mirrormode      => mirrormode,
        :syncusesubentry => syncusesubentry,
        :syncrepl        => syncrepl,
        :limits          => limits
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

  def default_confdir
    directories = { 'Debian' => '/etc/ldap/slapd.d',
                    'RedHat' => '/etc/openldap/slapd.d' }

    osfamily = Facter.value(:osfamily)

    directories[osfamily] if directories.keys.include?(osfamily)
  end

  # TODO: REPLACE THIS WITH AN LDIF AND LDAPMODIFY CALL. URGENT.
  def destroy
    backend = @property_hash[:backend]

    `service slapd stop`
    File.delete("#{default_confdir}/cn=config/olcDatabase={#{@property_hash[:index]}}#{backend}.ldif")

    lines = get_lines(slapcat("(objectClass=olc#{backend.to_s.capitalize}Config)"))

    dn_lines = lines.select do |dn|
      index = dn.
        match(/^dn: olcDatabase={(\d+)}#{backend},cn=config$/).
        captures.
        first.
        to_i

      index > @property_hash[:index]
    end

    dn_lines.each do |dn|
      index = dn[/\d+/].to_i

      old_filename = "#{default_confdir}/cn=config/olcDatabase={#{index}}#{backend}.ldif"
      new_filename = "#{default_confdir}/cn=config/olcDatabase={#{index - 1}}#{backend}.ldif"

      File.rename(old_filename, new_filename)
      text = File.read(new_filename)
      replace = text.gsub!("{#{index}}#{backend}", "{#{index - 1}}#{backend}")
      File.open(new_filename, "w") { |file| file.puts replace }
    end

    `service slapd start`
    @property_hash.clear
  end

  def initdb
    ldif = temp_ldif('openldap_database')

    ldif << dn(resource[:suffix])
    ldif << changetype(:add)
    ldif << "objectClass: top\n"
    ldif << "objectClass: dcObject\n" if resource[:suffix].start_with?("dc=")
    ldif << "objectClass: organization\n"
    ldif << "dc: #{resource[:suffix].split(/,?dc=/).delete_if { |c| c.empty? }[0]}\n" if resource[:suffix].start_with?("dc=")
    ldif << "o: #{resource[:suffix].split(/,?dc=/).delete_if { |c| c.empty? }.join('.')}\n" if resource[:suffix].start_with?("dc=")
    ldif << "\n"
    ldif << "dn: cn=admin,#{resource[:suffix]}\n"
    ldif << changetype(:add)
    ldif << "objectClass: simpleSecurityObject\n" if resource[:rootpw]
    ldif << "objectClass: organizationalRole\n"
    ldif << "cn: admin\n"
    ldif << "description: LDAP administrator\n"
    ldif << "userPassword: #{resource[:rootpw]}\n" if resource[:rootpw]
    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end
  end

  def create
    ldif = temp_ldif('openldap_database')
    ldif << dn("olcDatabase=#{resource[:backend]},cn=config")
    ldif << changetype(:add)
    ldif << "objectClass: olcDatabaseConfig\n"
    ldif << "objectClass: olc#{resource[:backend].to_s.capitalize}Config\n"
    ldif << "olcDatabase: #{resource[:backend]}\n"

    if "#{resource[:backend]}" != "monitor"
      ldif << "olcDbDirectory: #{resource[:directory]}\n" if resource[:directory]
      ldif << "olcSuffix: #{resource[:suffix]}\n" if resource[:suffix]
      ldif << "olcDbIndex: objectClass eq\n" if !resource[:dboptions] or !resource[:dboptions]['index']
    end

    ldif << "olcRootDN: #{resource[:rootdn]}\n" if resource[:rootdn]
    ldif << "olcRootPW: #{resource[:rootpw]}\n" if resource[:rootpw]
    ldif << "olcReadOnly: #{resource[:readonly] == :true ? 'TRUE' : 'FALSE'}\n" if resource[:readonly]
    ldif << "olcSizeLimit: #{resource[:sizelimit]}\n" if resource[:sizelimit]
    ldif << "olcTimeLimit: #{resource[:timelimit]}\n" if resource[:timelimit]
    ldif << "olcUpdateref: #{resource[:updateref]}\n" if resource[:updateref]

    if resource[:dboptions]
      resource[:dboptions].each do |k, v|
        case k
        when 'dbnosync'
          ldif << "olcDbNosync: #{v}\n"
        when 'dbpagesize'
          ldif << "olcDbPagesize: #{v}\n"
        when 'dbconfig'
          ldif << v.collect { |x| "olcDbConfig: #{x}" }.join("\n") + "\n"
        else
          if v.is_a?(Array)
            ldif << v.collect { |x| "olcDb#{k}: #{x}" }.join("\n") + "\n"
          else
            ldif << "olcDb#{k}: #{v}\n"
          end
        end
      end
    end

    ldif << resource[:syncrepl].collect { |x| "olcSyncrepl: #{x}" }.join("\n") + "\n" if resource[:syncrepl]
    ldif << "olcMirrorMode: #{resource[:mirrormode] == :true ? 'TRUE' : 'FALSE'}\n" if resource[:mirrormode]
    ldif << "olcSyncUseSubentry: #{resource[:syncusesubentry]}\n" if resource[:syncusesubentry]
    ldif << "#{resource[:limits].collect { |x| "olcLimits: #{x}" }.join("\n")}\n" if resource[:limits] and !resource[:limits].empty?
    ldif << "olcAccess: to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break\n"
    ldif << "olcAccess: to attrs=userPassword\n"
    ldif << "  by self write\n"
    ldif << "  by anonymous auth\n"
    ldif << "  by dn=\"cn=admin,#{resource[:suffix]}\" write\n"
    ldif << "  by * none\n"
    ldif << "olcAccess: to dn.base=\"\" by * read\n"
    ldif << "olcAccess: to *\n"
    ldif << "  by self write\n"
    ldif << "  by dn=\"cn=admin,#{resource[:suffix]}\" write\n"
    ldif << "  by * read\n"
    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end

    initdb if resource[:initdb] == :true

    @property_hash[:ensure] = :present

    objectClass = "olc#{resource[:backend].to_s.capitalize}Config"

    slapcat("(&(objectClass=#{objectClass})(olcSuffix=#{resource[:suffix]}))").split("\n").collect do |line|
      if line =~ /^olcDatabase: /
        @property_hash[:index] = line.match(/^olcDatabase: \{(\d+)\}#{resource[:backend]}$/).captures.first
      end
    end
  end

  def initialize(value = {})
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

  def readonly=(value)
    @property_flush[:readonly] = value
  end

  def sizelimit=(value)
    @property_flush[:sizelimit] = value
  end

  def timelimit=(value)
    @property_flush[:timelimit] = value
  end

  def updateref=(value)
    @property_flush[:updateref] = value
  end

  def dboptions=(value)
    @property_flush[:dboptions] = value
  end

  def mirrormode=(value)
    @property_flush[:mirrormode] = value
  end

  def syncusesubentry=(value)
    @property_flush[:syncusesubentry] = value
  end

  def syncrepl=(value)
    @property_flush[:syncrepl] = value
  end

  def limits=(value)
    @property_flush[:limits] = value
  end

  def flush
    if not @property_flush.empty?
      ldif = temp_ldif('openldap_database')
      ldif << dn("olcDatabase={#{@property_hash[:index]}}#{resource[:backend]},cn=config")
      ldif << changetype(:modify)
      ldif << "replace: olcDbDirectory\nolcDbDirectory: #{resource[:directory]}\n-\n" if @property_flush[:directory]
      ldif << "replace: olcRootDN\nolcRootDN: #{resource[:rootdn]}\n-\n" if @property_flush[:rootdn]
      ldif << "replace: olcRootPW\nolcRootPW: #{resource[:rootpw]}\n-\n" if @property_flush[:rootpw]
      ldif << "replace: olcSuffix\nolcSuffix: #{resource[:suffix]}\n-\n" if @property_flush[:suffix]
      ldif << "replace: olcReadOnly\nolcReadOnly: #{resource[:readonly] == :true ? 'TRUE' : 'FALSE'}\n-\n" if @property_flush[:readonly]
      ldif << "replace: olcSizeLimit\nolcSizeLimit: #{resource[:sizelimit]}\n-\n" if @property_flush[:sizelimit]
      ldif << "replace: olcTimeLimit\nolcTimeLimit: #{resource[:timelimit]}\n-\n" if @property_flush[:timelimit]
      ldif << "replace: olcUpdateref\nolcUpdateref: #{resource[:updateref]}\n-\n" if @property_flush[:updateref]

      if @property_flush[:dboptions]
        if "#{resource[:synctype]}" == "inclusive" and !@property_hash[:dboptions].empty?
          @property_hash[:dboptions].keys.each do |key|
            case key
            when 'dbnosync'
              ldif << "delete: olcDbNosync\n-\n"
            when 'dbpagesize'
              ldif << "delete: olcDbPagesize\n-\n"
            when 'dbconfig'
              ldif << "delete: olcDbConfig\n-\n"
            else
              ldif << "delete: olcDb#{key}\n-\n"
            end
          end
        end

        @property_flush[:dboptions].each do |key, value|
          case key
          when 'dbnosync'
            ldif << "replace: olcDbNosync\nolcDbNosync: #{value}\n-\n"
          when 'dbpagesize'
            ldif << "replace: olcDbPagesize\nolcDbPagesize: #{value}\n-\n"
          when 'dbconfig'
            ldif << "replace: olcDbConfig\n"
            ldif << value.collect { |x| "olcDbConfig: #{x}" }.join("\n")
            ldif << "\n-\n"
          else
            if v.is_a?(Array)
              ldif << "replace: olcDb#{k}\n"
              ldif << value.collect { |x| "olcDb#{key}: #{x}" }.join("\n")
              ldif << "\n-\n"
            else
              ldif << "replace: olcDb#{key}\nolcDb#{key}: #{value}\n-\n"
            end
          end
        end
      end

      ldif << "replace: olcSyncrepl\n#{resource[:syncrepl].collect { |x| "olcSyncrepl: #{x}" }.join("\n")}\n-\n" if @property_flush[:syncrepl]
      ldif << "replace: olcMirrorMode\nolcMirrorMode: #{resource[:mirrormode] == :true ? 'TRUE' : 'FALSE'}\n-\n" if @property_flush[:mirrormode]
      ldif << "replace: olcSyncUseSubentry\nolcSyncUseSubentry: #{resource[:syncusesubentry]}\n-\n" if @property_flush[:syncusesubentry]
      ldif << "replace: olcLimits\n#{@property_flush[:limits].collect { |x| "olcLimits: #{x}" }.join("\n")}\n-\n" if @property_flush[:limits]
      ldif.close

      ldif_content = IO.read(ldif.path)

      Puppet.debug(ldif_content)

      begin
        ldapmodify(ldif.path)

      rescue Exception => e
        raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
      end

      initdb if @property_flush[:directory]
    end

    @property_hash = resource.to_hash
  end
end
