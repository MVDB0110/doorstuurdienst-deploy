#Setup mariadb on database server
#
# @param secure_installation
# Specify whether mysql will be installed and configured by this manifest.
#
# @param setupapidb
# Specify whether the forward database for the api will be created.
#
# @param rootpassword
# Specify the root password for mysql_secure_installation.
#
# @param dbuser
# Specify the username that will be used by the api to use the forward database.
#
# @param dbpassword
# Specify the password for the user that will be used by the api to use the forward database.
#
# @param dbhost
# Specify the database host.
#
# @param dbpermissions
# Specify the permissions for the created user.
#
# @param dbname
# Specify the name for the database that will be used by the api.
#
class forward::sql (
  Boolean $secure_installation  = true,
  Boolean $setupapidb           = true,
  Boolean $apiconfig            = true,
  $rootpassword                 = 'P@ssw0rd',
  $dbuser                       = 'api',
  $dbpassword                   = 'password',
  $dbhost                       = 'localhost',
  $dbpermissions                = [ 'SELECT', 'UPDATE', 'INSERT', 'DELETE' ],
  $dbname                       = 'forward',
  ) {

  if $secure_installation {
    # Install mariadb on the database server
    class { '::mysql::server':
      root_password           => $rootpassword,
      remove_default_accounts => true,
      restart                 => true,
    }

  }

  if $setupapidb {
    # Ensure the configuration file for the forward database on the database server
    file { '/tmp/forward.sql':
      ensure => present,
      source => 'puppet:///modules/forward/forward.sql',
    }

    # Setup forward database on database server
    mysql::db { $dbname:
      user     => $dbuser,
      password => $dbpassword,
      host     => $dbhost,
      grant    => $dbpermissions,
      sql      => '/tmp/forward.sql',
      require  => File['/tmp/forward.sql'],
    }

  }

  if $apiconfig {
    $apidblink = "'mysql+pymysql://${dbuser}:${dbpassword}@${dbhost}:3306/${dbname}'"

    file { '/opt/doorstuurdienst/config.py':
      ensure  => file,
      mode    => '0755',
      content => template('forward/config.py.erb'),
    }

  }

}
