require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

Puppet::Type.
  type(:openldap_dbindex).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    # TODO: restict to bdb and hdb
    i = []
    slapcat('(olcDbIndex=*)').split("\n\n").collect do |paragraph|
      suffix = nil
      attrlist = nil
      indices = nil
      attribute = nil
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcSuffix: /
          suffix = line.split(' ')[1]
        when /^olcDbIndex: /
          attrlist, dummy, indices = line.match(/^olcDbIndex: (\S+)(\s+(.+))?$/).captures
          attrlist.split(',').each { |attribute|
            i << new(
              :name      => "#{attribute} on #{suffix}",
              :ensure    => :present,
              :attribute => attribute,
              :suffix    => suffix,
              :indices   => indices
            )
          }
        end
      end
    end
    i
  end

  def self.prefetch(resources)
    dbindexes = instances
    resources.keys.each do |name|
      if provider = dbindexes.find{ |access|
        access.attribute == resources[name][:attribute] && access.suffix == resources[name][:suffix]
      }
        resources[name].provider = provider
      end
    end
  end

  def getDn(suffix)
    slapcat("(olcSuffix=#{suffix})").split("\n").collect do |line|
      if line =~ /^dn: /
        return line.split(' ')[1]
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    t = Tempfile.new('openldap_dbindex')
    t << "dn: #{getDn(resource[:suffix])}\n"
    t << "add: olcDbIndex\n"
    t << "olcDbIndex: #{resource[:attribute]} #{resource[:indices]}\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify(t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
  end

  def indices=(value)
    current_olcDbIndex = getCurrentOlcDbIndex(resource[:suffix])

    t = Tempfile.new('openldap_dbindex')
    t << "dn: #{getDn(resource[:suffix])}\n"
    t << "changetype: modify\n"
    t << "replace: olcDbIndex\n"
    current_olcDbIndex.each do |olcDbIndex|
    if olcDbIndex[:attribute].to_s == resource[:attribute].to_s
        t << "olcDbIndex: #{resource[:attribute]} #{resource[:indices]}\n"
    else
        t << "olcDbIndex: #{olcDbIndex[:attribute]} #{olcDbIndex[:indices]}\n"
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

  def getCurrentOlcDbIndex(suffix)
    i = []
    slapcat("(olcDbIndex=*)", getDn(suffix)).split("\n\n").collect do |paragraph|
      paragraph.gsub("\n ", '').split("\n").collect do |line|
        case line
        when /^olcDbIndex: /
          attribute, indices = line.match(/^olcDbIndex:\s+(\S+)\s+(.*)$/).captures
          i << {
            :attribute => attribute,
            :indices => indices,
          }
        end
      end
    end
    return i
  end

end
