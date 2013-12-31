require 'spec_helper'

describe 'openldap' do

  let(:facts) {{
    :osfamily => 'Debian',
  }}

  context 'with no parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('openldap').with({
      :client => true,
      :server => true,
    })}
    it { should contain_class('openldap::client') }
    it { should contain_class('openldap::server') }
  end

end
