# frozen_string_literal: true

Puppet::Type.newtype(:openldap_module) do
  @doc = 'Manages OpenLDAP modules.'

  ensurable

  newparam(:name) do
    desc 'The default namevar.'
  end

  newparam(:target)
end
