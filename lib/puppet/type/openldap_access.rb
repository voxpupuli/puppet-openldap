Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
    desc "The default namevar"
  end

  newparam(:target) do
    desc "The slapd.conf file"
  end

  newparam(:what) do
    desc "The entries and/or attributes to which the access applies"
    isnamevar
  end

  newparam(:suffix) do
    desc "The suffix to which the access applies"
    isnamevar
    defaultto(nil)
  end

  def self.title_patterns
    [
      [
        /^(to\s+(\S+)\s+on\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /^(to\s+(\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
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

  newproperty(:by, :array_matching => :all) do
    desc "Array of hashes that specifies the ACL."
    def is_to_s(currentvalue)
      currentvalue.inspect
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    munge do |value|
      value['access'] ||= nil
      value['control'] ||= nil
      value
    end
  end

end
