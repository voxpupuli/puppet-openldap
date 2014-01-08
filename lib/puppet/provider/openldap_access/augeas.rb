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
    "$target/database[suffix='#{resource[:suffix]}']/access to[.='#{resource[:what]}']"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target/database').map { |dpath|
	suffix = aug.get("#{dpath}/suffix")
        aug.match("#{dpath}/access to").map { |hpath|
          what = aug.get(hpath)
          new(
            :name   => "#{what} on #{suffix}",
            :ensure => :present,
            :target => target,
	    :suffix => suffix,
	    :what   => what
          )
	}
      }.flatten
    end
  end

  def set_byes(aug, byes)
    byes.each do |by|
      aug.defnode('by', '$resource/by[last()+1]', nil)
      aug.set('$by/who', by['who'])
      aug.set('$by/what', by['access']) unless by['access'].nil?
      aug.set('$by/control', by['control']) unless by['control'].nil?
    end
  end

  define_aug_method!(:create) do |aug, resource|
    if aug.match("$target/database[suffix='#{resource[:suffix]}']").empty?
      raise Puppet::Error, "openldap_access: could not find database with suffix #{resource[:suffix]}"
    end
    aug.defnode('resource', resource_path(resource), resource[:what])
    set_byes(aug, resource[:by])
  end

  def by
    augopen do |aug, resource|
      aug.match('$resource/by').map do |by|
        {
          'who'     => aug.get("#{by}/who"),
          'access'  => aug.get("#{by}/what"),
          'control' => aug.get("#{by}/control")
        }
      end
    end
  end

  def by=(byes)
    augopen! do |aug, resource|
      aug.rm('$resource/by')
      set_byes(aug, byes)
    end
  end

end

