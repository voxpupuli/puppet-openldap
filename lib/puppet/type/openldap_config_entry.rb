Puppet::Type.newtype(:openldap_config_entry) do

  ensurable

  desc 'Represents one line or key value pair in the configuration file or database'

  newparam(:name, :namevar => true) do
    desc <<-EOS
    Unique representation of this line or key value pair. If a global
    configuration entry needs to be changed or deleted, use `ensure =>
    absent`.

    Note: This type is supposed to be used by the manifest
    openldap::server::globalconf. If you wish to use it directly, make sure to
    mimic its behaviour by setting the namevar with a correct hash.
    EOS
  end

  newparam(:target) do
    desc 'The provider to use: `olc` or `augeas`'

    defaultto :olc
  end

  newparam(:replace) do
    desc <<-EOS
    Whether or not to replace any current value. If set to yes or true any
    values already present will be replaced with the LDIF operation `replace:
    <key>`. If set to no or false, the attribute will be added unless the very
    same value is present already.

    Defaults to false.
    EOS

    defaultto :true
    newvalues(:true, :false)#, 'true', 'false')

    #munge do |value|
    #  [:true, 'true'].include?(value)
    #end
  end

  newproperty(:key) do
    desc <<-EOS
    The key for this configuration entry (e.g. "LogLevel" for `olcLogLevel`).

    When using the `olc` provider, the "olc" prefix will be added
    automatically. It is recommended leave it out, but supplying it works as
    well.
    EOS

    validate do |key|
      valid_keys = /(olc)?[a-zA-Z]+/
      unless valid_keys =~ key
        fail("invalid key '#{key}'. Keys must be characters only and may start
             with 'olc'  (#{valid_keys.inspect})")
      end
    end
  end

  newproperty(:value) do
    desc <<-EOS
    The value for this configuration entry. Must be a string.
    EOS

    validate do |value|
      unless value.is_a?(String)
        fail("'value' must be a String not '#{value.class.inspect}'")
      end
    end
  end
end
