# Setup Application Programmable Interface on destined servers
#
# @param port
# Specify the port where the api can be reached from.
#
# @param gitlink
# Specify the place where the api can be pulled from.
#
# @param servicename
# Specify the name of the service file. Default: api.service.
#
# @param manageservicefile
# Specify whether to create the api systemd service file.
#
# @param managepackage
# Whether or not install the packages.
#
class forward::api (
  $port                      = '5000',
  $gitlink                   = 'https://mvdb0110:1c2df1a1b147f0babad50944589c581c7e73b42b@github.com/MVDB0110/doorstuurdienst',
  $servicename               = 'api.service',
  Boolean $managepackage     = true,
  Boolean $manageservicefile = true,
  ) {
  # Class to reload systemd service files
  include forward::systemdreload

  # Push apiserver as balancermember for service API
  @@haproxy::balancermember { $::fqdn:
    listening_service => 'API',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress_eth0,
    ports             => $port,
    options           => 'check',
  }

  if $managepackage {
    # Pip packages to install for a good working API.
    $pippackage = [flask,flask-restful,flask-sqlalchemy,flask-marshmallow,marshmallow,marshmallow-sqlalchemy,connexion,pymysql]

    # Setup Python3
    package { 'python3':
      ensure => installed,
      before => Package['git'],
    }

    # Setup Git for Github Pull of API
    package { 'git':
      ensure => installed,
      before => Vcsrepo['/opt/doorstuurdienst'],
    }

    # Install pip packages
    package { $pippackage:
      ensure    => 'installed',
      provider  => 'pip3',
      subscribe => Package['python3'],
    }

  }

  # Pull API from Github.
  vcsrepo { '/opt/doorstuurdienst':
    ensure   => latest,
    provider => git,
    source   => $gitlink,
  }

  # Class to setup MariaDB
  class { 'forward::sql': }

  if $manageservicefile {
    # Setup API service file.
    file { 'api-service':
      path   => "/lib/systemd/system/${servicename}",
      mode   => '0644',
      source => 'puppet:///modules/forward/api.service',
      notify => Class['forward::systemdreload'],
    }
  }

  # Enable API service file and execute it.
  service { $servicename:
    ensure    => running,
    enable    => true,
    subscribe => Class['forward::systemdreload'],
  }

}
