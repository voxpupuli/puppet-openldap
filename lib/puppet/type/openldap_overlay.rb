Puppet::Type.newtype(:openldap_overlay) do
  @doc = 'Manages OpenLDAP Overlays'

  ensurable

  newparam(:name) do
    desc "The default namevar"
  end

  newparam(:target) do
    desc "The slapd.conf file"
  end

  newparam(:overlay, :namevar => true) do
    desc "The name of the overlay to apply"
  end

  newparam(:suffix, :namevar => true) do
    desc "The suffix to which the overlay applies"
  end

  def self.title_patterns
    [
      [
        /^((\S+)\s+on\s+(\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :overlay, lambda{|x| x} ],
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

  newproperty(:options) do
    desc "Overlay options."
  end

end

