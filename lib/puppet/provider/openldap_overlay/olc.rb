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
      paragraph.split("\n").collect do |line|
        case line
        when /^dn: /
          overlay, database = line.match(/^dn: olcOverlay=\{\d+\}([^,]+),olcDatabase=([^,]+),cn=config$/).captures
          suffix = getSuffix(database)
	end
      end
      new(
        :name    => "#{overlay} on #{suffix}",
        :ensure  => :present,
        :overlay => overlay,
        :suffix  => suffix
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
    t << "objectClass: olcMemberOf\n" if resource[:overlay] == 'memberof'
    t << "olcOverlay: #{resource[:overlay]}\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
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
    slapcat(
      '-b',
      'cn=config',
      '-H',
      "ldap:///???(olcDatabase=#{database})"
    ).split("\n").collect do |line|
      if line =~ /^olcSuffix: /
        return line.split(' ')[1]
      end
    end
  end

end
