Facter.add(:openldap_server_version) do
  setcode do
    Facter::Util::Resolution.exec('slapd -VV 2>&1').split("\n")[1][/\d+\.\d+\.\d+/]
  end
end
