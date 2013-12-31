class openldap(
  $client = true,
  $server = true,
) {
  if $client {
    class { 'openldap::client': }
  }
  if $server {
    class { 'openldap::server': }
  }
}
