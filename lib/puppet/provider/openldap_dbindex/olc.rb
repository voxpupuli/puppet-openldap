require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

require 'tempfile'

Puppet::Type.
  type(:openldap_dbindex).
  provide(:olc, :parent => Puppet::Provider::Openldap) do

  defaultfor :osfamily => :debian, :osfamily => :redhat

  mk_resource_methods

  def self.instances
    entries = get_entries(slapcat('(olcDbIndex=*)')).collect do |entry|
      suffix    = nil
      attrlist  = nil
      indices   = nil
      attribute = nil

      suffix_line = entry.find { |line| line =~ /^olcSuffix/ }
      suffix = last_of_split(suffix_line)

      entry.select { |line| line =~ /^olcDbIndex: / }.collect do |line|
        attributes, dummy, indices = line.
          match(/^olcDbIndex: (\S+)(\s+(.+))?$/).
          captures

        attributes.split(',').collect do |attribute|
          new(
            :name      => "#{attribute} on #{suffix}",
            :ensure    => :present,
            :attribute => attribute,
            :suffix    => suffix,
            :indices   => indices
          )
        end.flatten.compact
      end.flatten.compact
    end.compact.flatten

    entries
  end

  def self.prefetch(resources)
    dbindexes = instances

    resources.keys.each do |name|
      provider = dbindexes.find do |index|
        index.attribute == resources[name][:attribute] &&
          index.suffix == resources[name][:suffix]
      end

      resources[name].provider = provider if provider
    end
  end

  def getDn(suffix)
    Puppet.debug("suffix #{suffix}")
    entry = get_entries(slapcat("(olcSuffix=#{suffix})")).first
    Puppet.debug(entry.inspect)
    dn_line = entry.find { |line| (line =~ /^dn: /) != nil }
    Puppet.debug("dn_line for suffix #{suffix}: #{dn_line.inspect}")

    last_of_split(dn_line)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    ldif = temp_ldif('openldap_dbindex')
    ldif << dn(getDn(resource[:suffix]))
    ldif << changetype(:modify)
    ldif << add(:DbIndex)
    ldif << "olcDbIndex: #{resource[:attribute]} #{resource[:indices]}\n"
    ldif.close

    ldif_content = IO.read(ldif.path)

    Puppet.debug(ldif_content)

    begin
      ldapmodify(ldif.path)

    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{ldif_content}\nError message: #{e.message}"
    end
  end

  def indices=(value)
    current_olcDbIndex = getCurrentOlcDbIndex(resource[:suffix])

    ldif = temp_ldif('openldap_dbindex')
    ldif << "dn: #{getDn(resource[:suffix])}\n"
    ldif << "changetype: modify\n"
    ldif << "replace: olcDbIndex\n"

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
    get_lines(slapcat("(olcDbIndex=*)", getDn(suffix))).collect do |line|
      case line
      when /^olcDbIndex: /
        attribute, indices = line.match(/^olcDbIndex:\s+(\S+)\s+(.*)$/).captures

        { :attribute => attribute,
          :indices   => indices }
      end
    end
  end
end
