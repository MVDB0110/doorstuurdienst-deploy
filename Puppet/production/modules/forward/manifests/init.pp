# Setup All nodes
#
# @param telegraf_database_name
# Specify the name for the telegraf database.
#
# @param telegraf_database_user
# Specify the user for the telegraf database.
#
# @param telegraf_database_password
# Specify the password for the telegraf user.
#
class forward (
  $telegraf_database_name     = 'telegraf',
  $telegraf_database_user     = 'telegraf',
  $telegraf_database_password = 'P@ssw0rd',
  ) {
  #Setup all loadbalancers
  node /^hn-fwlo-\d{0,}.forwards.hostnetbv.nl$/ {
    #Setup HAproxy on loadbalancers
    include forward::haproxy

    #Setup Keepalived on loadbalancers
    include forward::keepalived

    # Setup monitoring
    class { 'forward::monitor':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
    }
  }
  node /^hn-fwwe-\d{0,}.forwards.hostnetbv.nl$/ {
    #Setup HTTPserver on forwardservers
    include forward::http

    # Setup monitoring
    class { 'forward::monitor':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
    }
  }
  node /^hn-fwap-\d{0,}.forwards.hostnetbv.nl$/ {
    #Setup Application Programmable Interface on destined servers
    include forward::api

    # Setup monitoring
    class { 'forward::monitor':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
    }
  }
  node /^master.forwards.hostnetbv.nl$/ {
    # Setup PuppetDB on Master
    include forward::puppetdb

    # Setup Puppetboard on Master
    include forward::board

    # Setup monitoring
    class { 'forward::monitor':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
    }
  }
  node /^hn-fwnm-0.forwards.hostnetbv.nl$/ {
    # Setup InfluxDB on NMS
    class { 'forward::influxdb':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
      before            => Class['forward::nms'],
    }

    # Setup Grafana on NMS
    class { 'forward::nms':
      allow_sign_up     => false,
      apiversion        => 1,
      datasource_name   => 'InfluxDB',
      type              => 'influxdb',
      access            => 'proxy',
      orgid             => '1',
      url               => 'http://localhost:8086',
      database_password => $telegraf_database_password,
      database_user     => $telegraf_database_user,
      database_name     => $telegraf_database_name,
      isDefault         => true,
    }

    # Setup monitoring
    class { 'forward::monitor':
      database_name     => $telegraf_database_name,
      database_user     => $telegraf_database_user,
      database_password => $telegraf_database_password,
    }
  }
}
