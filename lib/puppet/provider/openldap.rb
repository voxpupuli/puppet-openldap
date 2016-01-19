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

  def cn_config()
    dn('cn=config')
  end

  def get_entries(items)
    items.
      gsub("\n ", "").
      split("\n").
      select  { |entry| entry =~ /^olc/ }.
      collect { |entry| entry.gsub(/^olc/, '') }
  end


  def temp_ldif()
    Tempfile.new('openldap_global_conf')
  end

  def dn(dn)
    "dn: #{dn}\n"
  end

  def add(key)
    "add: olc#{key}\n"
  end

  def del(key)
    "delete: olc#{key}\n"
  end

  def replace(key)
    "replace: olc#{key}\n"
  end

  def key_value(key, value)
    "olc#{key}: #{value}\n"
  end

end
