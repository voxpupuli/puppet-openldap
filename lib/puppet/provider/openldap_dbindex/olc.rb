# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. openldap]))

# rubocop:disable Naming/VariableName
# rubocop:disable Naming/MethodName
# rubocop:disable Lint/AssignmentInCondition
Puppet::Type.
  type(:openldap_dbindex).
  provide(:olc, parent: Puppet::Provider::Openldap) do
  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor osfamily: %i[debian freebsd redhat suse]

  mk_resource_methods

  def self.instances
    # TODO: restict to bdb and hdb
    i = []
    slapcat('(olcDbIndex=*)').split("\n\n").map do |paragraph|
      suffix = nil
      attrlist = nil
      indices = nil
      paragraph.gsub("\n ", '').split("\n").map do |line|
        case line
        when %r{^olcSuffix: }
          suffix = line.split[1]
        when %r{^olcDbIndex: }
          attrlist, indices = line.match(%r{^olcDbIndex: (\S+)(?:\s+(.+))?$}).captures
          i << new(
            name: "#{attrlist} on #{suffix}",
            ensure: :present,
            attribute: attrlist,
            suffix: suffix,
            indices: indices
          )
        end
      end
    end
    i
  end

  def self.prefetch(resources)
    dbindexes = instances
    resources.each_key do |name|
      next unless provider = dbindexes.find do |access|
        access.attribute == resources[name][:attribute] && access.suffix == resources[name][:suffix]
      end

      resources[name].provider = provider
    end
  end

  def getDn(suffix)
    slapcat("(olcSuffix=#{suffix})").split("\n").map do |line|
      return line.split[1] if line =~ %r{^dn: }
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
    Puppet.debug(File.read(t.path))
    begin
      ldapmodify(t.path)
    rescue StandardError => e
      raise Puppet::Error, "LDIF content:\n#{File.read t.path}\nError message: #{e.message}"
    end
  end

  def indices=(_value)
    current_olcDbIndex = getCurrentOlcDbIndex(resource[:suffix])

    t = Tempfile.new('openldap_dbindex')
    t << "dn: #{getDn(resource[:suffix])}\n"
    t << "changetype: modify\n"
    t << "replace: olcDbIndex\n"
    current_olcDbIndex.each do |olc_db_index|
      t << if olc_db_index[:attribute].to_s == resource[:attribute].to_s
             "olcDbIndex: #{resource[:attribute]} #{resource[:indices]}\n"
           else
             "olcDbIndex: #{olc_db_index[:attribute]} #{olc_db_index[:indices]}\n"
           end
    end
    t.close
    Puppet.debug(File.read(t.path))
    begin
      ldapmodify(t.path)
    rescue StandardError => e
      raise Puppet::Error, "LDIF content:\n#{File.read t.path}\nError message: #{e.message}"
    end
  end

  def getCurrentOlcDbIndex(suffix)
    i = []
    slapcat('(olcDbIndex=*)', getDn(suffix)).split("\n\n").map do |paragraph|
      paragraph.gsub("\n ", '').split("\n").map do |line|
        case line
        when %r{^olcDbIndex: }
          attribute, indices = line.match(%r{^olcDbIndex:\s+(\S+)\s+(.*)$}).captures
          i << {
            attribute: attribute,
            indices: indices,
          }
        end
      end
    end
    i
  end
end
# rubocop:enable Naming/VariableName
# rubocop:enable Naming/MethodName
# rubocop:enable Lint/AssignmentInCondition
