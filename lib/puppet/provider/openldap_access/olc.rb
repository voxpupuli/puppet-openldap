require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_access).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    # Not sure this is needed. But will restrict to mdb, hdb, bdb, frontend
    # and config for now.
    entries = get_entries(slapcat('(olcAccess=*)')).select do |entry|
      entry.first.strip =~
        /^dn: olcDatabase.*(mdb|hdb|bdb|frontend|config),cn=config$/
    end

    rules = entries.collect do |entry|
      access = nil
      suffix = nil
      position = nil

      access_lines  = entry.select { |line| line =~ /^olcAccess: / }
      database_line = entry.detect { |line| line =~ /^olcDatabase: / }
      suffix_line ||= entry.detect { |line| line =~ /^olcSuffix: / }

      unless database_line.nil?
        suffix = "cn=#{last_of_split(database_line).gsub(/\{-?\d+\}/, '')}"
      end

      unless suffix_line.nil?
        suffix = last_of_split(suffix_line)
      end

      access_lines.collect do |line|
        access = []
        position, what, bys =
          line.
          match(/^olcAccess:\s+\{(\d+)\}to\s+(\S+)(\s+by\s+.*)+$/).
          captures

        access = bys.strip.split(/(?= by .+)/).collect(&:lstrip).reject { |by| by.empty? }
        islast = (position.to_i + 1) == get_count_for_entry(entry)

        Puppet.debug(">>> INSTANCES access #{access.inspect}")

        params = {
          :name     => "#{position} to #{what} on #{suffix}",
          :ensure   => :present,
          :position => position,
          :what     => what,
          :access   => [access].flatten.compact,
          :suffix   => suffix,
          :islast   => islast
	}

        new(params)
      end.flatten.compact
    end.flatten.compact

    Puppet.debug(">>> [INSTANCES olcAccess] #{rules.inspect}")

    rules
  end

  def self.normalize_access(access)
    [access].flatten.compact.reject { |s| s.empty? }.collect(&:strip)
  end

  def self.prefetch(resources)
    resources.keys.each do |name|
      provider = instances().find do |instance|
        access_instance = normalize_access(instance.access)
        access_resource = normalize_access(resources[name][:access])

        Puppet.debug(">>> PREFETCH what #{instance.what} | #{resources[name][:what]}")
        Puppet.debug(">>> PREFETCH access #{access_instance} | #{access_resource}")
        Puppet.debug(">>> PREFETCH suffix #{instance.suffix} | #{resources[name][:suffix]}")

        instance.what   == resources[name][:what] &&
        access_instance  == access_resource &&
        instance.suffix == resources[name][:suffix]
      end

      resources[name].provider = provider if provider
    end
  end

  def self.getDn(suffix)
    return 'olcDatabase={-1}frontend,cn=config' if suffix == 'cn=frontend'
    return 'olcDatabase={0}config,cn=config'    if suffix == 'cn=config'

    suffix = 'monitor' if suffix == 'cn=monitor'

    dn_line = get_entries(slapcat("(olcSuffix=#{suffix})")).
      first.
      detect { |line| line =~ /^dn: / }

    return dn_line.nil? ? nil : dn_line.split(' ', 2).last
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    position = ''
    position = "{#{resource[:position]}}" if resource[:position]

    ldif = temp_ldif('openldap_access')

    ldif << dn(self.class.getDn(resource[:suffix]))
    ldif << changetype(:modify)
    ldif << add(:Access)
    ldif << "olcAccess: #{position}to #{resource[:what]}\n"

    resource[:access].flatten.compact.each { |a| ldif << "  #{a}\n" }

    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      cnconfig = slapcat('(olcAccess=*)')
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}\n\n\n#{cnconfig}"
    end
  end

  def destroy
    ldif = temp_ldif('openldap_access')
    ldif << dn(self.class.getDn(@property_hash[:suffix]))
    ldif << changetype(:modify)
    ldif << del(:Access)
    ldif << "olcAccess: {#{@property_hash[:position]}}\n"

    if resource[:islast]
      ldif << "\n\n"
      ldif << dn(getDn(resource[:suffix]))
      ldif << changetype(:modify)
      ldif << del(:Access)

      from = resource[:position].to_i + 1
      to   = get_count_for_suffix(resource[:suffix])

      (from..to).each { |n| ldif << "olcAccess: {#{n}}\n" }
    end

    t.close

    Puppet.debug(IO.read t.path)

    slapdd('-b', 'cn=config', '-l', t.path)
  end

  def initialize(value = {})
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
    Puppet.debug("access= #{value.inspect}")
    @property_flush[:access] = value.flatten.compact
  end

  def islast=(value)
    @property_flush[:islast] = value
  end

  def self.get_count_for_entry(entry)
    entry.reduce(0) do |count, line|
      count += 1 if line =~ /^olcAccess: /
      count
    end
  end

  def self.get_count_for_suffix(suffix)
    get_count_for_entry(
      get_entries(
        slapcat('(olcAccess=*)', getDn(suffix))
      ).first
    )
  end

  def get_current(suffix)
    entries = self.class.get_entries(self.class.slapcat('(olcAccess=*)', self.class.getDn(suffix)))

    entries.collect do |entry|
      entry.
        select { |line| line =~ /^olcAccess: / }.
        collect do |line|
          position, content = line.match(/^olcAccess:\s+\{(\d+)\}(.*)$/).captures

          { :position => position,
            :content  => content }
        end
    end.flatten.compact
  end

  def flush
    return if @property_flush.empty?

    current_olcAccess = get_current(resource[:suffix])
    position          = resource[:position] ||
                        @property_hash[:position]
    ldif              = temp_ldif('openldap_access')

    ldif << dn(self.class.getDn(resource[:suffix]))
    ldif << changetype(:modify)
    ldif << replace_key(:Access)

    Puppet.debug(current_olcAccess.inspect)

    current_olcAccess.each do |current|
      if current[:position].to_i == position.to_i
        ldif << "olcAccess: {#{position}}to #{resource[:what]}\n"

        resource[:access].flatten.compact.each { |a| ldif << "  #{a}\n" }
      else
        ldif << "olcAccess: {#{current[:position]}}#{current[:content]}\n"
      end
    end

    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end

    @property_hash = resource.to_hash
  end
end
