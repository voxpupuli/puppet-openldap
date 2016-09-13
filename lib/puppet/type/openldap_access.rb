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
  end

  def self.title_patterns
    [
      [
        /^(\{(\d+)\}to\s+(\S+)\s+(by\s+.+)\s+on\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :position, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :access, lambda{ |x| a=[]; x.split(/(?= by .+)/).each { |b| a << b.lstrip }; a } ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /^(\{(\d+)\}to\s+(\S+)\s+(by\s+.+)\s+)$/,
        [
          [ :name, lambda{|x| x} ],
          [ :position, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :access, lambda{ |x| a=[]; x.split(/(?= by .+)/).each { |b| a << b.lstrip }; a } ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+(by\s+.+)\s+on\s+(.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :access, lambda{ |x| a=[]; x.split(/(?= by .+)/).each { |b| a << b.lstrip }; a } ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+(by\s+.+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :access, lambda{ |x| a=[]; x.split(/(?= by .+)/).each { |b| a << b.lstrip }; a } ],
        ],
      ],
      [
        /^((\d+)\s+on\s+(.+))$/,
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

  autorequire(:openldap_database) do
    [ value(:suffix) ]
  end

end
