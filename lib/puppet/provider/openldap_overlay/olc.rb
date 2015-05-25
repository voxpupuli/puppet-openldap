require 'tempfile'

Puppet::Type.type(:openldap_overlay).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances
    slapcat(
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(olcOverlay=*)'
    ).split("\n\n").collect do |paragraph|
      overlay = nil
      suffix = nil
      index = nil
      options = Array.new
      paragraph.split("\n").collect do |line|
        case line
        when /^dn: /
          index, overlay, database = line.match(/^dn: olcOverlay=\{(\d+)\}([^,]+),olcDatabase=([^,]+),cn=config$/).captures
          suffix = getSuffix(database)
        when /^olcOverlay: /i
        when /^olc([a-zA-Z]+): /i
          opt_k, opt_n = line.split(': ', 2)
          if opt_n =~ /^\{\d+\}(.+)$/ then
            opt_n = opt_n.split('}', 2)[1]
          end
          options.push("#{opt_k}: #{opt_n}")
        end
      end
      options = options.empty? ? nil : options.sort
      new(
        :name    => "#{overlay} on #{suffix}",
        :ensure  => :present,
        :overlay => overlay,
        :suffix  => suffix,
        :index   => index.to_i,
        :options => options,
      )
    end
  end

  def self.prefetch(resources)
    overlays = instances
    resources.keys.each do |name|
      if provider = overlays.find{ |overlay| overlay.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    t = Tempfile.new('openldap_overlay')
    t << "dn: olcOverlay=#{resource[:overlay]},#{getDn(resource[:suffix])}\n"
    t << "changetype: add\n"
    t << "objectClass: olcConfig\n"
    t << "objectClass: olcOverlayConfig\n"
    case resource[:overlay]
    when 'memberof'
      t << "objectClass: olcMemberOf\n"
    when 'ppolicy'
      t << "objectClass: olcPPolicyConfig\n"
    when 'dynlist'
      t << "objectClass: olcDynamicList\n"
    end
    #t << "objectClass: olcMemberOf\n" if resource[:overlay] == 'memberof'
    t << "olcOverlay: #{resource[:overlay]}\n"
    if resource[:options]
      resource[:options].each do |opt|
        t << opt.split(':')[0] + ": " + opt.split(':', 2)[1]
      end
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      system "cat " + t.path
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
  end

  def getDn(suffix)
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

  def self.getSuffix(database)
    found = false
    slapcat(
      '-b',
      'cn=config',
      '-H',
      "ldap:///???(olcDatabase=#{database})"
    ).split("\n").collect do |line|
      if line =~ /^dn: olcDatabase=#{database.gsub('{', '\{').gsub('}','\}')},/
        found = true
      end
      if line =~ /^olcSuffix: / and found
        return line.split(' ')[1]
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def options=(value)
    @property_flush[:options] = value
  end

  def flush
    if not @property_flush.empty?
      t = Tempfile.new('openldap_overlay')
      t << "dn: olcOverlay={#{@property_hash[:index]}}#{resource[:overlay]},#{getDn(resource[:suffix])}\n"
      t << "changetype: modify\n"
      if @property_flush[:options] then
        # Convert to hash so it was easier
        hash = {}
        @property_flush[:options].each do |opt|
          opt_n, opt_v = opt.split(': ', 2)
          if hash.has_key?(opt_n) then
            if hash[opt_n].is_a?(Array) then
              hash[opt_n].push(opt_v)
            else
              hash[opt_n] = [hash[opt_n]].push(opt_v)
            end
          else
            hash[opt_n] = opt_v
          end
        end
        hash.each do |k, v|
          t << "replace: #{k}\n" + ( v.respond_to?('collect') ? v.collect { |x| "#{k}: #{x}" }.join("\n") + "\n" : "#{k}: #{v}\n" ) + "-\n"
        end
        # We could remove some option...
        if @property_hash[:options] then
          [@property_hash[:options]].flatten.each do |opt|
            key = opt.split(': ', 2)[0]
            if not hash.has_key?(key) then
              t << "delete: #{key}\n-\n"
            end
          end
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
    @property_has = resource.to_hash
  end

  def getPath(dn)
    dn.split(',').reverse.join('/') + ".ldif"
  end

  def destroy
    # TODO: I'm not sure that this works when there are more overlays in the
    # database
    default_confdir = Facter.value(:osfamily) == 'Debian' ? '/etc/ldap/slapd.d' : Facter.value(:osfamily) == 'RedHat' ? '/etc/openldap/slapd.d' : nil

    `service slapd stop`
    path = default_confdir  + "/" + getPath("olcOverlay={#{@property_hash[:index]}}#{resource[:overlay]},#{getDn(resource[:suffix])}")
    File.delete(path)
    slapcat('-b', 'olcDatabase={2}hdb,cn=config', '-H', "ldap:///???objectClass=olcOverlayConfig"
           ).split("\n").select { |line| line =~ /^dn: / }.select { |dn| dn.match(/^dn: olcOverlay=\{(\d+)\}(.+),olcDatabase=\{2\}hdb,cn=config$/).captures[0].to_i > @property_hash[:index] }.each { |dn|
             index, type = dn.match(/^dn: olcOverlay=\{(\d+)\}(.+),olcDatabase=\{2\}hdb,cn=config$/).captures
             index = index.to_i
             old_filename = "#{default_confdir}/#{getPath(dn.split(' ',2)[1])}"
             new_filename = "#{default_confdir}/#{getPath("olcOverlay={#{index - 1}}#{type},#{getDn(@property_hash[:suffix])}")}"

             File.rename(old_filename, new_filename)
             text = File.read(new_filename)
             replace = text.gsub("{#{index}}#{type}", "{#{index - 1}}#{type}")
             File.open(new_filename, "w") { |file| file.puts replace }
           }
    `service slapd start`
    @property_hash.clear
  end

end
