require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))
require 'tempfile'

Puppet::Type.
  type(:openldap_access).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => [:debian, :redhat]

  mk_resource_methods

  def self.instances
    # TODO: restict to bdb, hdb and globals
    i = []
    slapcat('(olcAccess=*)').split("\n\n").collect do |paragraph|
      access = nil
      suffix = nil
      position = nil
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcDatabase: /
          suffix = "cn=#{line.split(' ')[1].gsub(/\{-?\d+\}/, '')}"
        when /^olcSuffix: /
          suffix = line.split(' ')[1]
        when /^olcAccess: /
          position, what, bys = line.match(/^olcAccess:\s+\{(\d+)\}\s*to\s+(\S+(?:\s+filter=\S+)?(?:\s+attrs=\S+)?)(\s+by\s+.*)+$/).captures
          access = []
          bys.split(/(?= by .+)/).each { |b|
            access << b.lstrip
          }
          if (position.to_i + 1) == getCountOfOlcAccess(suffix)
            islast = true
          else
            islast = false
          end
          i << new(
            :name     => "{#{position}}to #{what} #{access.join(' ')} on #{suffix}",
            :ensure   => :present,
            :position => position,
            :what     => what,
            :access   => access,
            :suffix   => suffix,
            :islast   => islast
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
        if resources[name][:position]
          access.suffix == resources[name][:suffix] &&
          access.position == resources[name][:position]
        else
          access.suffix == resources[name][:suffix] &&
          access.access == resources[name][:access] &&
          access.what == resources[name][:what]
        end
      }
        resources[name].provider = provider
      end
      validate_islast(resources)
    end
  end

  def self.validate_islast(resources)
    islast = {}
    resources.keys.each do |name|
      if resources[name][:islast] == true
        if islast[resources[name][:suffix]].nil?
          islast[resources[name][:suffix]] = resources[name][:name]
        else
          raise Puppet::Error, "Multiple 'islast' found for suffix '#{resources[name][:suffix]}': #{resources[name][:name]} and #{islast[:suffix]}"
        end
      end
    end
  end

  def self.getDn(suffix)
    if suffix == 'cn=frontend'
      return 'olcDatabase={-1}frontend,cn=config'
    elsif suffix == 'cn=config'
      return 'olcDatabase={0}config,cn=config'
    elsif suffix.downcase == 'cn=monitor'
      slapcat('(olcDatabase=monitor)').split("\n").collect do |line|
        if line =~ /^dn: /
          return line.split(' ')[1]
        end
      end
    else
      slapcat("(olcSuffix=#{suffix})").split("\n").collect do |line|
        if line =~ /^dn: /
          return line.split(' ')[1]
        end
      end
    end
  end
  def getDn(*args); self.class.getDn(*args); end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    position = "{#{resource[:position]}}" if resource[:position]
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(resource[:suffix])}\n"
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
      ldapmodify(t.path)
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
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
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

  def islast=(value)
    @property_flush[:islast] = value
  end

  def self.getCountOfOlcAccess(suffix)
    countOfElement = 0
    slapcat("(olcAccess=*)","#{getDn(suffix)}").split("\n\n").collect do |paragraph|
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcAccess: /
          countOfElement = countOfElement + 1
        end
      end
    end
    return countOfElement
  end

  def getCurrentOlcAccess(suffix)
    i = []
    slapcat("(olcAccess=*)","#{getDn(suffix)}").split("\n\n").collect do |paragraph|
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
      t << "dn: #{getDn(resource[:suffix])}\n"
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
      countOfElement = self.class.getCountOfOlcAccess(resource[:suffix])
      if resource[:islast] and countOfElement > position.to_i+1
        t << "-\n"
        t << "delete: olcAccess\n"
        (position.to_i+1..countOfElement-1).each do |n|
          t << "olcAccess: {#{n}}\n"
        end
      end
      t.close
      Puppet.debug(IO.read t.path)
      begin
        ldapmodify(t.path)
      rescue Exception => e
        raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end


end
