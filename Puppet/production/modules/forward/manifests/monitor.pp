# Setup Telegraf
#
# @param telegrafdir
# Specify the directory of telegraf configuration.
#
# @param managepackage
# Whether or not install packages.
#
# @param manageconf
# Whether or not to configure the installed packages.
#
class forward::monitor (
  Boolean $managepackage  = true,
  Boolean $manageconf     = true,
  $database_name          = 'telegraf',
  $database_user          = 'telegraf',
  $database_password      = 'P@ssw0rd',
  $influxdb_host          = 'http://10.0.2.253:8086',
  $telegrafdir            = '/etc/telegraf',
  ) {

  if $managepackage and $manageconf {
    if $::osfamily == 'RedHat' {
      $packages = [ telegraf, conntrack ]

      file { 'influxdb.repo':
        ensure => file,
        path   => '/etc/yum.repos.d/influxdb.repo',
        mode   => '0644',
        source => 'puppet:///modules/forward/influxdb.repo'
      }

      package { $packages:
        ensure  => 'latest',
        require => File['influxdb.repo'],
        before  => File['telegraf-conf'],
      }

    } elsif $::operatingsystem == 'Ubuntu' {
      $packages = [ telegraf, conntrack, conntrackd ]

      apt::source { 'influxdb':
        ensure   => present,
        location => 'https://repos.influxdata.com/ubuntu',
        release  => $::lsbdistcodename,
        repos    => 'stable',
        key      => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
      }

      package { $packages:
        ensure  => 'latest',
        require => Apt::Source['influxdb'],
        before  => File['telegraf-conf'],
      }

    }

    file { 'telegraf-conf':
      ensure  => file,
      path    => "${telegrafdir}/telegraf.conf",
      mode    => '0755',
      content => template('forward/telegraf.conf.erb'),
      notify  => Service['telegraf'],
    }

    service { 'telegraf':
      ensure    => 'running',
      enable    => true,
    }
  }

  if ($managepackage) and ($manageconf == false) {
    package { $packages:
      ensure => 'latest',
      notify => Service['telegraf'],
    }

    service { 'telegraf':
      ensure    => 'running',
      enable    => true,
      subscribe => Package['telegraf'],
    }
  }
}
