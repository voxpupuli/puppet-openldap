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
    "$target/database[suffix = '#{resource[:suffix]}']/access to[. = '#{resource[:what]}']"
  end

  def self.instances
    resources = []
    augopen do |aug|
      aug.match('$target/database').each { |dpath|
	suffix = aug.get("#{dpath}/suffix")
        aug.match("#{dpath}/access to").each { |hpath|
          what = aug.get(hpath)
          resources << new(
            :name      => "#{what} on #{suffix}",
            :ensure    => :present,
            :target    => target,
	    :suffix    => suffix,
	    :what      => what
          )
	}
      }
    end
    resources
  end

end

