# Setup Grafana and InfluxDB
#
# @param allow_sign_up
# Specify whether users of Grafana can sign up.
#
# @param apiversion
# Specify the version of the api of Grafana.
#
# @param datasource_name
# Specify the name of the datasource.
#
# @param type
# Specify the type of datasource that will be created.
#
# @param access
# Access type of datasource.
#
# @param orgid
# Specify the organizationid associated with the datasource.
#
# @param url
# Specify the url of the datasource.
#
# @param database_password
# Specify the password used to connect to influxdb and provision influxdb.
#
# @param database_user
# Specify the username used to connect to influxdb and provision influxdb.
#
# @param database_name
# Specify the name of the database that will be used to connect to influxdb and provision influxdb.
#
# @param isDefault
# Specify if this is the default datasource.
#
class forward::nms (
  Boolean $allow_sign_up     = false,
  $apiversion                = 1,
  $datasource_name           = 'InfluxDB',
  $type                      = 'influxdb',
  $access                    = 'proxy',
  $orgid                     = '1',
  $url                       = 'http://localhost:8086',
  $database_password         = 'P@ssw0rd',
  $database_user             = 'telegraf',
  $database_name             = 'telegraf',
  Boolean $isDefault         = true,
  ) {

  class { 'grafana':
    cfg                      => {
      users           => {
        allow_sign_up => $allow_sign_up,
      },
    },
    provisioning_datasources => {
      apiVersion  => $apiversion,
      datasources => [
        {
          name      => $datasource_name,
          type      => $type,
          access    => $access,
          orgId     => $orgid,
          url       => $url,
          password  => $database_password,
          user      => $database_user,
          database  => $database_name,
          isDefault => $isDefault,
        },
      ],
    },
    provisioning_dashboards => {
      apiVersion => 1,
      providers  => [
        {
          name            => 'default',
          orgId           => 1,
          folder          => '',
          type            => 'file',
          disableDeletion => true,
          options         => {
            path         => '/var/lib/grafana/dashboards',
            puppetsource => 'puppet:///modules/forward/dashboards',
          },
        },
      ],
    },
    subscribe                => Class['forward::influxdb'],
  }

}
