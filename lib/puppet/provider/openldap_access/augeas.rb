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

  resource_path do |resource|
    "$target/database[suffix='#{resource[:suffix]}']/access to[.='#{resource[:what]}']/by[who='#{resource[:by]}']"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target/database/access to/by').map { |by|
        suffix = aug.get("#{by}/../../suffix")
        what = aug.get("#{by}/..")
        by = aug.get("#{by}/who")
        new(
          :name    => "to #{what} on #{suffix} by #{by}",
          :ensure  => :present,
          :what    => what,
          :suffix  => suffix,
          :by      => by,
          :access  => aug.get("#{by}/what"),
          :control => aug.get("#{by}/control"),
          :target  => target
        )
      }
    end
  end

  define_aug_method!(:create) do |aug, resource|
    if aug.match("$target/database[suffix='#{resource[:suffix]}']").empty?
      raise Puppet::Error, "openldap_access: could not find database with suffix #{resource[:suffix]}"
    end
    aug.defnode('access', "$target/database[suffix='#{resource[:suffix]}']/access to[.='#{resource[:what]}']", resource[:what])
    aug.defnode('resource', "$access/by/who[.=#{resource[:by]}]/who", resource[:by])
    attr_aug_writer_access(aug, resource[:access])
    attr_aug_writer_control(aug, resource[:control])
  end

  attr_aug_accessor(:access, :label => 'what')
  attr_aug_accessor(:control)
end

