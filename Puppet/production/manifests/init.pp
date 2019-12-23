#Setup Hiera HTTP gem
package { 'lookup_http':
  ensure   => 'installed',
  provider => 'puppet_gem',
  before   => Class['forward'],
}

if $::osfamily == 'RedHat' {
  class { 'selinux':
    mode => 'permissive',
    type => 'targeted',
  }
}

# Setup All nodes
class { 'forward':
  telegraf_database_name     => 'telegraf',
  telegraf_database_user     => 'telegraf',
  telegraf_database_password => 'P@ssw0rd',
}
