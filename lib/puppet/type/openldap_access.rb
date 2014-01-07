Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
  end

  newparam(:suffix) do
  end

  newparam(:what) do
  end

  newparam(:target) do
  end

  newproperty(:by, :array_matching => :all) do
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
