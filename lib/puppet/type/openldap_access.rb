# frozen_string_literal: true

Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
    desc 'The default namevar'
  end

  newparam(:target) do
    desc 'The slapd.conf file'
  end

  newparam(:position) do
    desc 'Where to place the new entry'
  end

  newproperty(:what) do
    desc 'The entries and/or attributes to which the access applies'
  end

  newparam(:suffix) do
    desc 'The suffix to which the access applies'
  end

  newproperty(:access, array_matching: :all) do
    desc 'Access rule.'
    munge do |v|
      if v.is_a?(String)
        a = []
        v.split(%r{(?= by .+)}).each do |b|
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
        %r{^((\d+)\s+on\s+(.+))$},
        [
          [:name],
          [:position],
          [:suffix],
        ],
      ],
    ]
  end

  autorequire(:openldap_database) do
    [value(:suffix)]
  end
end
