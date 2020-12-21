require 'spec_helper'

describe Puppet::Type.type(:openldap_global_conf).provider(:olc) do
  samples = { 
    'new and changed global values': {
      description: 'replaces changed or missing global configuration',
      params:     {
        title: 'GlobalValues1',
        name: 'GlobalValues1',
        value: {
          'LogLevel' => 'somelogs',
          'ArgsFile' => 'sopmeargsfile'
        },
        provider: described_class.name,
      },
      slapcatdata: %q{dn: cn=config
objectClass: olcGlobal
cn: config
olcArgsFile: /var/run/openldap/slapd.args
olcPidFile: /var/run/openldap/slapd.pid
},
      ldapmodifydata: %q{dn: cn=config
add: olcLogLevel
olcLogLevel: somelogs
-
replace: olcArgsFile
olcArgsFile: sopmeargsfile
-
}
    },
    'existing values ar the same': {
      description: 'does nothing when the values are the same in slapcat',
      params:     {
        title: 'GlobalValues2',
        name: 'GlobalValues2',
        value: {
          'LogLevel' => 'somelogs',
          'ArgsFile' => 'sopmeargsfile'
        },
        provider: described_class.name,
      },
      slapcatdata: %q{dn: cn=config
objectClass: olcGlobal
cn: config
olcPidFile: /var/run/openldap/slapd.pid
olcLogLevel: somelogs
olcArgsFile: sopmeargsfile
},
      ldapmodifydata: %q{dn: cn=config
}
    },
    'non of the values exist': {
      description: 'creates values when none are in slapcat',
      params:     {
        title: 'GlobalValues3',
        name: 'GlobalValues3',
        value: {
          'LogLevel' => 'somelogs',
          'ArgsFile' => 'sopmeargsfile'
        },
        provider: described_class.name,
      },
      slapcatdata: %q{dn: cn=config
objectClass: olcGlobal
cn: config
},
      ldapmodifydata: %q{dn: cn=config
add: olcLogLevel
olcLogLevel: somelogs
-
add: olcArgsFile
olcArgsFile: sopmeargsfile
-
}
    }
  }
  samples.each do |test, v|
    let(:params) do
      v[:params]
    end
    let(:resource) do
      Puppet::Type.type(:openldap_global_conf).new(params)
    end

    let(:provider) do
      resource.provider
    end

    describe test do
      it v[:description] do
        provider.class.stubs(:slapcat).returns(v[:slapcatdata])
        provider.class.define_singleton_method(:ldapmodify) do |arg|
          ldif =  IO.read arg
          if ldif != v[:ldapmodifydata]
            raise "ldapmodify did not have expected ldif\n>#{v[:ldapmodifydata]}<" 
          end
        end
        provider.value
        if provider.exists?
          puts "called value="
          provider.value=()
        else
          puts "called create"
          provider.create
        end
      end
    end
  end
end
