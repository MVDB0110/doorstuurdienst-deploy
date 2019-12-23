# Install InfluxDB
#
# @param dbname
# Specify the name for the telegraf database.
#
# @param dbuser
# Specify the user for the telegraf database.
#
# @param dbpassword
# Specify the password for the telegraf user.
#
# @param managepackage
# Whether or not install the influxdb package.
#
# @param manageinfluxdb
# Whether or not to configure the telegraf database in influxdb. This option override dbname, dbuser and dbpassword.
#
class forward::influxdb (
  $database_name          = 'telegraf',
  $database_user          = 'telegraf',
  $database_password      = 'P@ssw0rd',
  Boolean $managepackage  = true,
  Boolean $manageinfluxdb = true,
  ) {

  if $managepackage {
    package { ['influxdb', 'influxdb-client']:
      ensure  => 'installed',
      notify  => Service['influxdb'],
    }

    service { 'influxdb':
      ensure  => 'running',
      enable  => true,
      require => Package['influxdb'],
    }

  }

  if $manageinfluxdb {
    exec { 'influxdb_dbcreate':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'CREATE DATABASE ${database_name}'",
      require => Package['influxdb-client'],
      before  => Exec['influxdb_usercreate'],
      unless  => "influx -execute 'SHOW DATABASES' | tail -n+3 | awk '{print \$1}' | grep -x ${database_name}",
    }

    exec { 'influxdb_admincreate':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute \"CREATE USER admin WITH PASSWORD 'P@ssw0rd' WITH ALL PRIVILEGES\"",
      require => Package['influxdb-client'],
      unless  => "influx -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' | grep -x admin",
    }

    exec { 'influxdb_usercreate':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute \"CREATE USER ${database_user} WITH PASSWORD '${database_password}'\"",
      require => Package['influxdb-client'],
      unless  => "influx -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' | grep -x ${database_user}",
    }

    file { 'influx-conf':
      ensure => file,
      path   => '/etc/influxdb/influxdb.conf',
      source => 'puppet:///modules/forward/influxdb.conf',
      notify => Service['influxdb'],
    }

  }

}
