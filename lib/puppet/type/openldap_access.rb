Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

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

  newproperty(:access, :array_matching => :all ) do
    desc "Access rule."
    munge do |v|
      if v.is_a?(String)
        a = []
        v.split(/(?= by .+)/).each do |b|
          a << b.lstrip
        end
        a
      else
        v
      end
    end

    def insync?(is)
      @should.flatten!
      super(is)
    end
  end

  def self.title_patterns
    [
      [
        /^(\{(\d+)\}to\s+(\S+)\s+(by\s+.+)\s+on\s+(.+))$/,
        [
          [ :name ],
          [ :position ],
          [ :what ],
          [ :access ],
          [ :suffix ],
        ],
      ],
      [
        /^(\{(\d+)\}to\s+(\S+)\s+(by\s+.+))$/,
        [
          [ :name ],
          [ :position ],
          [ :what ],
          [ :access ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+(by\s+.+)\s+on\s+(.+))$/,
        [
          [ :name ],
          [ :what ],
          [ :access ],
          [ :suffix ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+(by\s+.+))$/,
        [
          [ :name ],
          [ :what ],
          [ :access ],
        ],
      ],
      [
        /^((\d+)\s+on\s+(.+))$/,
        [
          [ :name ],
          [ :position ],
          [ :suffix ],
        ],
      ],
      [
        /(.*)/,
        [
          [ :name ],
        ],
      ],
    ]

  end

  autorequire(:openldap_database) do
    [ value(:suffix) ]
  end

end
