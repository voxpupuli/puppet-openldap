require File.dirname(__FILE__) + '/../../../../../augeasproviders/lib/augeasproviders/provider.rb'

Puppet::Type.type(:openldap_global_conf).provide(:augeas) do
  desc "Uses Augeas API to update OpenLDAP global configuration"

  include AugeasProviders::Provider

  default_file {
    case Facter[:osfamily].value
    when 'Debian'
      '/etc/ldap/slapd.conf'
    when 'RedHat'
      '/etc/openldap/slapd.conf'
    end
  }

  lens { 'Slapd.lns' }

  openldap23 = Gem::Version.new(Facter[:openldap_server_version].value) >= Gem::Version.new('2.3.0')

  defaultfor :openldap23 => false
  confine :feature => :augeas
  confine :exists => target

  resource_path do |resource|
    "$target/#{resource[:name]}"
  end

  def self.instances
    augopen do |aug|
      aug.match('$target/*[label()!="#comment"]').map { |hpath|
        new(
          :name   => path_label(aug, hpath),
          :ensure => :present,
          :target => target,
          :value  => aug.get(hpath),
	)
      }
    end
  end

  attr_aug_accessor(:value, :label => :resource)

end
