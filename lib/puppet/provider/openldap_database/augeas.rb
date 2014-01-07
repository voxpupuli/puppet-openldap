require File.dirname(__FILE__) + '/../../../../../augeasproviders/lib/augeasproviders/provider.rb'

Puppet::Type.type(:openldap_database).provide(:augeas) do
  desc "Uses Augeas API to update OpenLDAP databases"

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
    "$target/database[suffix = #{resource[:name]}]"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target/database').map { |hpath|
        new(
          :name      => aug.get("#{hpath}/suffix"),
          :ensure    => :present,
          :target    => target,
	  :backend   => aug.get(hpath),
	  :directory => aug.get("#{hpath}/directory"),
	  :rootdn    => aug.get("#{hpath}/rootdn"),
	  :rootpw    => aug.get("#{hpath}/rootpw")
	)
      }
    end
  end

  attr_aug_accessor(:directory, :label => :resource)
  attr_aug_accessor(:rootdn, :label => :resource)
  attr_aug_accessor(:rootpw, :label => :resource)

end

