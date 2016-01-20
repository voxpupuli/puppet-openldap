class Puppet::Provider::Openldap < Puppet::Provider

  initvars # without this, commands won't work

  defaultfor :osfamily => :debian,
             :osfamily => :redhat

  commands :slapcat    => 'slapcat',
           :ldapmodify => 'ldapmodify'

  @delimit   = "-\n"

  def method_missing(method_name, *args)
    if self.class.respond_to?(method_name)
      return self.class.call(method_name.to_sym, *args) 
    end

    return super(method_name, *args)
  end

  def self.cn_config()
    dn('cn=config')
  end

  def self.get_entries(items)
    items.
      gsub("\n ", "").
      split("\n").
      select  { |entry| entry =~ /^olc/ }.
      collect { |entry| entry.gsub(/^olc/, '') }
  end


  def self.temp_ldif()
    Tempfile.new('openldap_global_conf')
  end

  def self.dn(dn)
    "dn: #{dn}\n"
  end

  def self.add(key)
    "add: olc#{key}\n"
  end

  def self.del(key)
    "delete: olc#{key}\n"
  end

  def self.replace(key)
    "replace: olc#{key}\n"
  end

  def self.key_value(key, value)
    "olc#{key}: #{value}\n"
  end
end
