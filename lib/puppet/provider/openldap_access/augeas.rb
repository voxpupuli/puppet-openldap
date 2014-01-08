require File.dirname(__FILE__) + '/../../../../../augeasproviders/lib/augeasproviders/provider.rb'

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

  openldap23 = Gem::Version.new(Facter.value(:openldap_server_version)) >= Gem::Version.new('2.3.0')

  defaultfor :openldap23 => false
  confine :feature => :augeas
  confine :exists => target

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

  define_aug_method!(:create) do |aug, resource|
    if resource[:suffix] and aug.match(base_path(resource)).empty?
      raise Puppet::Error, "openldap_access: could not find database with suffix #{resource[:suffix]}"
    end
    aug.defnode('access', "#{base_path(resource)}/access to[.='#{resource[:what]}' and by/who='#{resource[:by]}']", resource[:what])
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

