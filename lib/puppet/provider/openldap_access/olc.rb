require 'tempfile'

Puppet::Type.type(:openldap_access).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    # TODO: restict to bdb, hdb and globals
    i = []
    slapcat(
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(olcAccess=*)'
    ).split("\n\n").collect do |paragraph|
      access = nil
      suffix = nil
      position = nil
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcSuffix: /
          suffix = line.split(' ')[1]
        when /^olcAccess: /
          if suffix == nil
              suffix = 'cn=config'
          end
          position, what, bys = line.match(/^olcAccess:\s+\{(\d+)\}to\s+(\S+)(\s+by\s+.*)+$/).captures
          bys.split(' by ')[1..-1].each { |b|
            by, access, control = b.strip.match(/^(\S+)\s+(\S+)(\s+\S+)?$/).captures
            i << new(
              :name     => "to #{what} by #{by} on #{suffix}",
              :ensure   => :present,
              :position => position,
              :what     => what,
              :by       => by,
              :suffix   => suffix,
              :access   => access,
              :control  => control
            )
          }
        end
      end
    end

    i
  end

  def self.prefetch(resources)
    accesses = instances
    resources.keys.each do |name|
      if provider = accesses.find{ |access| access.name == name }
        resources[name].provider = provider
      end
    end
  end

  def getDn(suffix)
    if suffix == 'cn=config'
      return 'olcDatabase={0}config,cn=config'
    else
      slapcat(
        '-b',
        'cn=config',
        '-H',
        "ldap:///???(olcSuffix=#{suffix})"
      ).split("\n").collect do |line|
        if line =~ /^dn: /
          return line.split(' ')[1]
        end
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    position = "{#{resource[:position]}}" if resource[:position]
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(resource[:suffix])}\n"
    t << "add: olcAccess\n"
    t << "olcAccess: #{position}to #{resource[:what]} by #{resource[:by]} #{resource[:access]}\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
  end

  def destroy
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(@property_hash[:suffix])}\n"
    t << "changetype: modify\n"
    t << "delete: olcAccess\n"
    t << "olcAccess: {#{@property_hash[:position]}}\n"
    if resource[:islast]
      t << "\n\n"
      t << "dn: #{getDn(resource[:suffix])}\n"
      t << "changetype: modify\n"
      t << "delete: olcAccess\n"
      (resource[:position].to_i+1..getCountOfOlcAccess(resource[:suffix])).each do |n|
        t << "olcAccess: {#{n}}\n"
      end
    end
    t.close
    Puppet.debug(IO.read t.path)
    slapdd('-b', 'cn=config', '-l', t.path)
  end

  def access=(value)
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(@property_hash[:suffix])}\n"
    t << "changetype: modify\n"
    t << "delete: olcAccess\n"
    t << "olcAccess: {#{@property_hash[:position]}}\n"
    t << "-\n"
    t << "add: olcAccess\n"
    t << "olcAccess: {#{@property_hash[:position]}}to #{resource[:what]} by #{resource[:by]} #{resource[:access]}\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
  end

  def getCountOfOlcAccess(suffix)
    countOfElement = 0
    slapcat(
      '-H',
      "ldap:///#{getDn(suffix)}???(olcAccess=*)"
    ).split("\n\n").collect do |paragraph|
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcAccess: /
          countOfElement = countOfElement + 1
        end
      end
    end
    return countOfElement
  end

end
