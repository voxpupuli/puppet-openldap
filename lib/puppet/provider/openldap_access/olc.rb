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
          position, access = line.match(/^olcAccess: \{(\d+)\}(.*)$/).captures
          i << new(
            :name     => "#{access} on #{suffix}",
            :ensure   => :present,
            :access   => access,
            :suffix   => suffix,
            :position => position
          )
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

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    position = "{#{resource[:position]}}" if resource[:position]
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(resource[:suffix])}\n"
    t << "add: olcAccess\n"
    t << "olcAccess: #{position}#{resource[:access]}\n"
    t.close
    #puts IO.read t.path
    ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
  end

  def destroy
    t = Tempfile.new('openldap_access')
    t << "dn: #{getDn(@property_hash[:suffix])}\n"
    t << "changetype: modify\n"
    t << "delete: olcAccess\n"
    t << "olcAccess: {#{@property_hash[:position]}}\n"
    t.close
    #puts IO.read t.path
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
    t << "olcAccess: {#{@property_hash[:position]}}#{resource[:access]}\n"
    t.close
    #puts IO.read t.path
    ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
  end

end
