# Install Puppetboard
#
# @param httpssldir
# Specify the place where the certificates are placed for puppetboard.
#
# @param httpconfdir
# Specify the directory where the httpd virtual host configs are placed.
#
# @param puppetssldir
# Specify the directory where the puppetcerts are placed.
#
# @param managepackage
# Whether or not install the packages.
#
class forward::board (
  $httpssldir            = '/etc/httpd/ssl',
  $httpconfdir           = '/etc/httpd/conf.d',
  $puppetssldir          = '/etc/puppetlabs/puppet/ssl',
  $docroot               = '/var/www/html/puppetboard',
  Boolean $managepackage = true,
  Boolean $managesebool  = true,
  ) {
  # Configure secure linux
  include selinux

  if $managepackage {
    # Yum packages to install for puppetboard
    $packages = [epel-release,python-pip,httpd,httpd-devel,python-devel,python3,python3-devel,mod_wsgi,gcc]
    package { $packages:
      ensure => 'installed',
    }

    # Pip packages to install for puppetboard
    $pippack = [mod-wsgi,puppetboard]

    # Install pip packages on Python3
    package { $pippack:
      ensure   => 'installed',
      provider => 'pip3',
    }

    # Install mod-wsgi on Python2
    package { 'pip-modwsgi':
      ensure   => 'installed',
      name     => 'mod-wsgi',
      provider => 'pip',
    }

    # Instal puppetboard on Python2
    package { 'pip-puppetboard':
      ensure   => 'installed',
      name     => 'puppetboard',
      provider => 'pip',
    }

    # Enable the httpd service and execute it.
    service { 'httpd':
      ensure    => 'running',
      enable    =>  true,
      subscribe => File['/etc/httpd/conf.d/puppetboard.conf'],
      require   => Package['httpd'],
    }

  }

  # Ensure the directory /var/www/html/puppetboard
  file { $docroot:
    ensure => directory,
    mode   => '0755',
    owner  => 'apache',
    group  => 'apache',
    before => File['/var/www/html/puppetboard/wsgi.py'],
  }

  # Ensure the WSGI python file
  file { "${docroot}/wsgi.py":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/forward/wsgi.py',
  }

  # Ensure the settings file for Puppetboard
  file { "${docroot}/settings.py":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/forward/settings.py',
  }

  # Ensure the ssl directory of httpd for the puppet certificates
  file { $httpssldir:
    ensure => directory,
    mode   => '0755',
  }

  # Ensure certs directory in the ssl directory.
  file { "${httpssldir}/certs":
    ensure => directory,
    mode   => '0755',
  }

  # Ensure the private directory in the ssl directory
  file { "${httpssldir}/private":
    ensure => directory,
    mode   => '0755',
  }

  # Ensure the private pem file for puppetboard of the private key from the puppetdb server
  file { "${httpssldir}/private/master.forwards.hostnetbv.nl.pem":
    ensure  => file,
    mode    => '0755',
    source  => "${puppetssldir}/private_keys/master.forwards.hostnetbv.nl.pem",
    require => File['/etc/httpd/ssl/private'],
  }

  # Ensure the public pem file for puppetboard of the public key from the puppetdb server
  file { "${httpssldir}//certs/master.forwards.hostnetbv.nl.pem":
    ensure  => file,
    mode    => '0755',
    source  => "${puppetssldir}/certs/master.forwards.hostnetbv.nl.pem",
    require => File['/etc/httpd/ssl/certs'],
  }

  # Ensure the pem file for puppetboard of the certificate authority from the puppetmaster server
  file { "${httpssldir}//certs/ca.pem":
    ensure  => file,
    mode    => '0755',
    source  => "${puppetssldir}/certs/ca.pem",
    require => File['/etc/httpd/ssl/certs'],
  }

  if $managesebool {
    # Ensure selinux boolean httpd can connect for puppetboard connections to the puppetdb
    selinux::boolean { 'httpd_can_network_connect': }
  }

  # Ensure the puppetboard virtual host configuration for httpd
  file { "${httpconfdir}/puppetboard.conf":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/forward/puppetboard.conf',
    notify => Service['httpd'],
  }

}
