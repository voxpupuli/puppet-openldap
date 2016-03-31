Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  def self.title_patterns
    [
      [
        /^((\S+)\s+on\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :position, lambda{|x| x} ],
          [ :suffix, lambda{|x| x} ],
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

  newparam(:name) do
    desc "The default namevar"
  end

  newparam(:target) do
    desc "The slapd.conf file"
  end

  newproperty(:islast) do
    desc "Is this olcAccess the last one?"
  end

  newproperty(:what) do
    desc "The entries and/or attributes to which the access applies"
  end

  newproperty(:suffix) do
    desc "The suffix to which the access applies"
  end

  newproperty(:position) do
    desc "Where to place the new entry"
  end

  newproperty(:access, :array_matching => :first) do
    desc "Access rule."

    munge do |rules|
      [rules].flatten.compact.reject { |rule| rule.empty? }
    end
  end

  autorequire(:openldap_database) do
    [ value(:suffix) ]
  end

end
