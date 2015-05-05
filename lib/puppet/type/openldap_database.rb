Puppet::Type.newtype(:openldap_database) do
  @doc = "Manages OpenLDAP BDB and HDB databases."

  ensurable

  newparam(:suffix, :namevar => true) do
    desc "The default namevar."
  end

  newparam(:target) do
  end

  newproperty(:index) do
    desc "The index of the database."
  end

  newproperty(:backend) do
    desc "The name of the backend."
    newvalues('bdb', 'hdb', 'mdb')
    defaultto do
      case Facter.value(:osfamily)
      when 'Debian'
        case Facter.value(:operatingsystem)
        when 'Debian'
          if Facter.value(:operatingsystemmajrelease).to_i < 8
            'hdb'
          else
            'mdb'
          end
        when 'Ubuntu'
          'hdb'
        else
          'hdb'
        end
      when 'RedHat'
        if Facter.value(:operatingsystemmajrelease).to_i < 7
          'bdb'
        else
          'hdb'
        end
      end
    end
  end

  newproperty(:directory) do
    desc "The directory where the BDB files containing this database and associated indexes live."
    defaultto '/var/lib/ldap'
  end

  newproperty(:rootdn) do
    desc "The distinguished name that is not subject to access control or administrative limit restrictions for operations on this database."
  end

  newproperty(:rootpw) do
    desc "Password (or hash of the password) for the rootdn."

    def insync?(is)
      if should =~ /^\{(CRYPT|MD5|SMD5|SSHA|SHA)\}.+/
        should == is
      else
        case is
        when /^\{CRYPT\}.+/
          "{CRYPT}" + should.crypt(is[0,2]) == is
        when /^\{MD5\}.+/
          "{MD5}" + Digest::MD5.hexdigest(should) == is
        when /^\{SMD5\}.+/
          salt = is[16..-1]
          md5_hash_with_salt = "#{Digest::MD5.digest(should + salt)}#{salt}"
          "{SMD5}#{[md5_hash_with_salt].pack('m').gsub("\n", '')}" == is
        when /^\{SSHA\}.+/
          decoded = Base64.decode64(is.gsub(/^\{SSHA\}/, ''))
          salt = decoded[20..-1]
          "{SSHA}" + Base64.encode64("#{Digest::SHA1.digest("#{should}#{salt}")}#{salt}").chomp == is
        when /^\{SHA\}.+/
          "{SHA}" + Digest::SHA1.hexdigest(should) == is
        else
          false
        end
      end
    end

    def sync
      require 'securerandom'
      salt = SecureRandom.random_bytes(4)
      @resource[:rootpw] = "{SSHA}" + Base64.encode64("#{Digest::SHA1.digest("#{should}#{salt}")}#{salt}").chomp
      super
    end

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created password"
      else
        return "changed password"
      end
    end

    def is_to_s( currentvalue )
      return '[old password hash redacted]'
    end
    def should_to_s( newvalue )
      return '[new password hash redacted]'
    end
  end
end
