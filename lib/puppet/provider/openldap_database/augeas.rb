begin
  require File.dirname(__FILE__) + '/../../../augeasproviders/provider.rb'
rescue LoadError
  begin
    # For local unit tests
    require File.dirname(__FILE__) + '/../../../../../augeasproviders/lib/augeasproviders/provider.rb'
  rescue LoadError
    # For travis unit tests
    require File.dirname(__FILE__) + '/../../../../spec/fixtures/modules/augeasproviders/lib/augeasproviders/provider.rb'
  end
end

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

  confine :feature => :augeas

  resource_path do |resource|
    "$target/database[suffix = '#{resource[:suffix]}']"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target/database').map { |hpath|
        new(
          :ensure    => :present,
          :name      => aug.get("#{hpath}/suffix"),
          :suffix    => aug.get("#{hpath}/suffix"),
          :target    => target,
          :backend   => aug.get(hpath),
          :directory => aug.get("#{hpath}/directory"),
          :rootdn    => aug.get("#{hpath}/rootdn"),
          :rootpw    => aug.get("#{hpath}/rootpw")
        )
      }
    end
  end

  attr_aug_accessor(:index)
  attr_aug_accessor(:backend, :label => :resource)
  attr_aug_accessor(:directory)
  attr_aug_accessor(:rootdn)
  attr_aug_accessor(:rootpw)

end
