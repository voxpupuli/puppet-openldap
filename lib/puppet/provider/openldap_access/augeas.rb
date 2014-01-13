begin
  require File.dirname(__FILE__) + '/../../../../../augeasproviders/lib/augeasproviders/provider.rb'
rescue LoadError
  require File.dirname(__FILE__) + '/../../../../spec/fixtures/modules/augeasproviders/lib/augeasproviders/provider.rb'
end

Puppet::Type.type(:openldap_access).provide(:augeas) do
  desc "Uses Augeas API to update OpenLDAP ACPs/ACLs"

  include AugeasProviders::Provider

  default_file {
    case Facter.value(:osfamily)
    when 'Debian'
      '/etc/ldap/slapd.conf'
    when 'RedHat'
      '/etc/openldap/slapd.conf'
    end
  }

  lens { 'Slapd.lns' }

  confine :feature => :augeas

  def self.base_path(resource)
    resource[:suffix].nil? ? '$target' : "$target/database[suffix='#{resource[:suffix]}']"
  end

  resource_path do |resource|
    "#{base_path(resource)}/access to[.='#{resource[:what]}']/by[who='#{resource[:by]}']"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target//access to/by').map { |b|
        what = aug.get("#{b}/..")
        suffix = aug.get("#{b}/../../suffix")
        by = aug.get("#{b}/who")
        name = suffix.nil? ? "to #{what} by #{by}" : "to #{what} by #{by} on #{suffix}"
        new(
          :name    => name,
          :ensure  => :present,
          :what    => what,
          :by      => by,
          :suffix  => suffix,
          :access  => aug.get("#{b}/what"),
          :control => aug.get("#{b}/control"),
          :target  => target
        )
      }
    end
  end

  def self.parse_position(position)
    position.match(/(before|after)\s+access\s+to\s+(\S+)\s+by\s+(\S+)/).captures
  end

  def self.access_path(what, by)
    "access to[.='#{what}' and by/who='#{by}']"
  end

  def self.position_path(resource)
    pos_before, pos_what, pos_by = self.parse_position(resource[:position])

    sibling_pos = (pos_before == 'before') ? 'following-sibling' : 'preceding-sibling'
    parent_level = "$resource[parent::access to[#{sibling_pos}::#{access_path(pos_what, pos_by)}]]"
    if pos_what == resource[:what]
      same_level = "$resource[#{sibling_pos}::by[who='#{pos_by}']]"
      "#{same_level}|#{parent_level}"
    else
      parent_level
    end
  end

  def in_position?
    unless resource[:position].nil?
      mpath = self.class.position_path(resource)
      augopen do |aug|
        !aug.match(mpath).empty?
      end
    end
  end

  define_aug_method!(:create) do |aug, resource|
    if resource[:suffix] and aug.match(base_path(resource)).empty?
      raise Puppet::Error, "openldap_access: could not find database with suffix #{resource[:suffix]}"
    end

    if resource[:position].nil?
      aug.defnode('access', "#{base_path(resource)}/#{self.access_path(resource[:what], resource[:by])}", resource[:what])
    else
      pos_before, pos_what, pos_by = self.parse_position(resource[:position])
      aug.insert("#{base_path(resource)}/#{self.access_path(pos_what, pos_by)}", 'access to', pos_before == 'before')
      aug.defvar('access', '$target//access to[count(by)=0]')
      aug.set('$access', resource[:what])
    end

    aug.defnode('resource', "$access/by[who='#{resource[:by]}']", nil)
    aug.set('$resource/who', resource[:by])
    attr_aug_writer_access(aug, resource[:access])
    attr_aug_writer_control(aug, resource[:control])
  end

  define_aug_method!(:destroy) do |aug, resource|
    aug.rm('$resource')
    # Purge empty access rules
    aug.rm("#{base_path(resource)}/access to[count(by)=0]")
  end

  attr_aug_accessor(:access, :label => 'what', :rm_node => true)
  attr_aug_accessor(:control, :rm_node => true)
end
