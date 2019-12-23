# Setup Keepalived on loadbalancers
#
# @param priorityserver
# Specify what loadbalancer has highest priority
#
# @param packages
# Specify what packages need to be installed
#
# @param confdir
# Specify directory of keepalived.
#
# @param managepackage
# Specify whether packages will be managed by this Puppet manifest.
#
# @param manageconfig
# Specify whether the config will be managed by this Puppet manifest.
#
class forward::keepalived (
  $priorityserver        = 'hn-fwlo-0.forwards.hostnetbv.nl',
  $packages              = [ psmisc, keepalived ],
  $confdir               = '/etc/keepalived',
  Boolean $managepackage = true,
  Boolean $manageconfig  = true,
  ) {

  # Set priority number for two server loadbalancer cluster
  if $trusted['certname'] == $priorityserver {
    $priority = 100
  } else {
    $priority = 99
  }

  if $managepackage and $manageconfig {
    # Packages for keepalived and keepalived configuration on the loadbalancer
    package { $packages:
      ensure => installed,
      before => File['conf-keepalived'],
    }

    # Ensure the configuration of keepalived
    file { 'conf-keepalived':
      path    => "${confdir}/keepalived.conf",
      mode    => '0644',
      content => template('forward/keepalived.conf.erb'),
    }

    # Enable the service of keepalived and execute it.
    service { 'keepalived':
      ensure    => running,
      enable    => true,
      subscribe => File['conf-keepalived'],
    }

  }

  if $managepackage and ($manageconfig == false) {
    # Packages for keepalived and keepalived configuration on the loadbalancer
    package { $packages:
      ensure => installed,
      notify => Service['keepalived'],
    }

    # Enable the service of keepalived and execute it.
    service { 'keepalived':
      ensure => running,
      enable => true,
    }

  }

}
