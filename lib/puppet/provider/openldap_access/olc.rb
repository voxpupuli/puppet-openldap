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
        when /^olc(Suffix|Database): /
          suffix = line.split(' ')[1].gsub(/\{\d+\}/, '')
        when /^olcAccess: /
          position, what, bys = line.match(/^olcAccess:\s+\{(\d+)\}to\s+(\S+)(\s+by\s+.*)+$/).captures
          access = []
          bys.split(/(?= by .+)/).each { |b|
            access << b.lstrip
          }
          i << new(
            :name     => "#{position} on #{suffix}",
            :ensure   => :present,
            :position => position,
            :what     => what,
            :access   => access,
            :suffix   => suffix,
          )
        end
      end
    end

    i
  end

  def self.prefetch(resources)
    accesses = instances
    resources.keys.each do |name|
      if provider = accesses.find{ |access|
        access.suffix == resources[name][:suffix] &&
        access.position == resources[name][:position]
      }
        resources[name].provider = provider
      end
    end
  end

  def self.getDn(suffix)
    if suffix == 'cn=frontend'
      return 'olcDatabase={-1}frontend,cn=config'
    elsif suffix == 'cn=config'
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
    t << "dn: #{self.class.getDn(resource[:suffix])}\n"
    t << "add: olcAccess\n"
    if resource[:position]
      t << "olcAccess: {#{resource[:position]}}to #{resource[:what]}\n"
    else
      t << "olcAccess: to #{resource[:what]}\n"
    end
    resource[:access].each do |a|
      t << "  #{a}\n"
    end
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
    t << "dn: #{self.class.getDn(@property_hash[:suffix])}\n"
    t << "changetype: modify\n"
    t << "delete: olcAccess\n"
    t << "olcAccess: {#{@property_hash[:position]}}\n"
    t.close
    Puppet.debug(IO.read t.path)
    slapdd('-b', 'cn=config', '-l', t.path)
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def what=(value)
    @property_flush[:what] = value
  end

  def suffix=(value)
    @property_flush[:suffix] = value
  end

  def position=(value)
    @property_flush[:position] = value
  end

  def access=(value)
    @property_flush[:access] = value
  end

  def getCurrentOlcAccess(suffix)
    i = []
    slapcat(
      '-H',
      "ldap:///#{self.class.getDn(suffix)}???(olcAccess=*)"
    ).split("\n\n").collect do |paragraph|
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcAccess: /
          position, content = line.match(/^olcAccess:\s+\{(\d+)\}(.*)$/).captures
          i << {
            :position => position,
            :content => content,
          }
        end
      end
    end
    return i
  end

  def flush
    if not @property_flush.empty?
      current_olcAccess = getCurrentOlcAccess(resource[:suffix])
      t = Tempfile.new('openldap_access')
      t << "dn: #{self.class.getDn(resource[:suffix])}\n"
      t << "changetype: modify\n"
      t << "replace: olcAccess\n"
      if resource[:position]
        position = resource[:position]
      else
        position = @property_hash[:position]
      end
      current_olcAccess.each do |olcAccess|
        if olcAccess[:position].to_i == position.to_i
          t << "olcAccess: {#{position}}to #{resource[:what]}\n"
          resource[:access].each do |a|
            t << "  #{a}\n"
          end
        else
          t << "olcAccess: {#{olcAccess[:position]}}#{olcAccess[:content]}\n"
        end
      end
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
