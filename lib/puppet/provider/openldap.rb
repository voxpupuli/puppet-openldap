class Puppet::Provider::Openldap < Puppet::Provider

  initvars # without this, commands won't work

  defaultfor :osfamily => :debian,
             :osfamily => :redhat

  commands :slapcat    => 'slapcat',
           :ldapmodify => 'ldapmodify'

  @delimit   = "-\n"

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


  def self.temp_ldif
    Tempfile.new('openldap_global_conf')
  end
  def temp_ldif
    self.class.temp_ldif
  end

  def self.dn(dn)
    "dn: #{dn}\n"
  end

  def self.add(key)
    "add: olc#{key}\n"
  end
  def add(key)
    self.class.add(key)
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
  def key_value(key, value)
    self.class.key_value(key, value)
  end
end
