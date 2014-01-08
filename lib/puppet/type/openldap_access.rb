require File.dirname(__FILE__) + '/../../../../augeasproviders/lib/augeasproviders/type.rb'

Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  extend AugeasProviders::Type

  positionable

  newparam(:name) do
    desc "The default namevar"
  end

  newparam(:target) do
    desc "The slapd.conf file"
  end

  newparam(:what, :namevar => true) do
    desc "The entries and/or attributes to which the access applies"
  end

  newparam(:by, :namevar => true) do
    desc "To whom the access applies"
  end

  newparam(:suffix, :namevar => true) do
    desc "The suffix to which the access applies"
  end

  def self.title_patterns
    [
      [
        /^(to\s+(\S+)\s+by\s+(.+)\s+on\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :by, lambda{|x| x} ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+by\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :by, lambda{|x| x} ],
        ],
      ],
      [
        /(.*)/,
        [
          [ :name, lambda{|x| x} ],
        ],
      ],
    ]
  end

  newparam(:position) do
    desc "Where to place the new entry"
    validate do |value|
      raise "Wrong position statement '#{value}'" unless value =~ /^(before|after)/
    end
  end

  newproperty(:access) do
    desc "Access rule."
  end

  newproperty(:control) do
    desc "Control rule."
  end

end
