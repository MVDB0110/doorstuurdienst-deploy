# Setup HTTPserver on forwardservers
#
# @param installation
# Manage Apache installation.
#
# @param setupcertbot
# Manage Cerbot configuration.
#
# @param certbotauth
# Specify the name of the datasource.
#
# @param ports
# Specify ports for the loadbalancermember.
#
# @param user
# Specify the Apache user (not which Apache will use. But for folder permissions.)
#
# @param defaultvhost_docroot
# Specify the docroot for the default vhosts
#
# @param forward_docroot
# Specify docroots for the forwards.
#
# @param letsencryptdir
# Specify the Letsencrypt certificates directory
#
# @param managepackage
# Manage apache package
#
# @param manageconf
# Manageconfiguration of Letsencrypt and Apache
#
class forward::http (
  $certbotauth            = 'webroot',
  $ports                  = { 'http' => '80', 'https' => '443' },
  $user                   = 'www-data',
  $defaultvhost_docroot   = '/var/www/html',
  $forward_docroot        = '/mnt/nfs/docroot',
  $letsencryptdir         = '/etc/letsencrypt/live',
  Boolean $managepackage  = true,
  Boolean $manageconf     = true,
  ) {

  # Push forwardserver as balancermember for listening service WebclusterNoSSL
  @@haproxy::balancermember { "${::fqdn}-NoSSL":
    listening_service => 'WebclusterNoSSL',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress,
    ports             => $ports['http'],
    options           => 'check',
  }

  # Push forwardserver as balancermember for listening service WebclusterSSL
  @@haproxy::balancermember { "${::fqdn}-SSL":
    listening_service => 'WebclusterSSL',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress,
    ports             => $ports['https'],
    options           => 'check',
  }

  if $managepackage {
    # Install Apache with virtualhost on port 80 and port 443.
    class { 'apache':
      default_vhost     => true,
      default_ssl_vhost => true,
      server_signature  => false,
      server_tokens     => 'Prod',
    }

    # Install Apache mod_headers, mod_http2 and mod_rewrite
    class { 'apache::mod::headers':
    }

    class { 'apache::mod::http2':
    }

    class { 'apache::mod::ssl':
      ssl_protocol => ['-all', '+TLSv1.2', '+TLSv1.3'],
    }

    class { 'apache::mod::rewrite':
    }
    
    class { 'apache::mod::status':
    }

    class { 'apache::mod::security':
    }

    # Setup Certbot for Letsencrypt Authorization
    class { 'letsencrypt':
      email  => 'mvandenbrink@hostnet.nl',
      config => {
        server => 'https://acme-v02.api.letsencrypt.org/directory',
      }

    }

  }

  if $manageconf {
    # Setup index.html for the default virtualhosts
    file { "${defaultvhost_docroot}/index.html":
      ensure  => file,
      owner   => $user,
      mode    => '0755',
      source  => 'puppet:///modules/forward/default.html',
    }

  }

  # Lookup all forwards
  $forwards = lookup( { 'name' => 'forwards', 'default_value' => [] } )

  # Loop through all forwards
  $forwards.each | $value | {
    # See if forward is archived
    if $value['archive'] == 'n' {
      # See if forward is activated
      if $value['provision'] == 'present' {
        # Ensure directory for forward
        file { "${forward_docroot}/${value['bron']}":
          ensure => directory,
          mode   => '2755',
          owner  => $user,
          group  => 'root',
        }

        # If forward is specified as frameforward the setup index.html
        if $value['methode'] == 'frame' {
          file { "${forward_docroot}/${value['bron']}/index.html":
            ensure  => file,
            mode    => '0755',
            owner   => $user,
            group   => $user,
            content => template('forward/iframe.html.erb'),
          }

        }

        # If forward is specified as 301-redirect then ensure index is absent
        else {
          file { "${forward_docroot}/${value['bron']}/index.html":
            ensure => absent,
            force  => true,
          }

        }

      }

      # If forward is archived remove docroot
      else {
        # Request certficate for the domain that will be forwarded
        letsencrypt::certonly { $value['bron']:
          ensure        => $value['provision'],
          domains       => [$value['bron']],
          plugin        => $certbotauth,
          webroot_paths => ["${forward_docroot}/${value['bron']}"],
          subscribe     => Exec['mpm-reload'],
        }

        # Delete docroot of forward if provision is absent.
        exec { "/bin/rm -rf ${forward_docroot}/${value['bron']}":
        }

      }

      # The non-ssl virtual host
      apache::vhost { "non-ssl-${value['bron']}":
        ensure          => $value['provision'],
        servername      => $value['bron'],
        port            => $ports['http'],
        docroot         => "${forward_docroot}/${value['bron']}",
        protocols       => ['h2','http/1.1'],
        directories     => {
          path    => "${forward_docroot}/${value['bron']}",
          options => '-Indexes +FollowSymLinks +MultiViews',
        },
        manage_docroot  => false,
        custom_fragment => '
  RewriteEngine on
  RewriteCond %{REQUEST_URI} "!/.well-known/acme-challenge/"
  RewriteRule (.*) https://%{HTTP_HOST} [NE,L,R=301]',
        notify          => Exec['mpm-reload'],
      }

    }

  }

  # Restart Apache to load the port 80 config files
  exec { 'mpm-reload':
    command     => '/bin/systemctl restart apache2.service && /bin/sleep 60',
    refreshonly => true,
  }


  $forwards.each | $value | {
    # See if forward is archived
    if $value['archive'] == 'n' {

      if $value['provision'] == 'present' {
        # Request certficate for the domain that will be forwarded
        letsencrypt::certonly { $value['bron']:
          ensure        => $value['provision'],
          domains       => [$value['bron']],
          plugin        => $certbotauth,
          webroot_paths => ["${forward_docroot}/${value['bron']}"],
          subscribe     => Exec['mpm-reload'],
        }

      }

      # See if forward is a 301-redirect
      if $value['methode'] == '301' {
        # The SSL virtual host at the same domain 301 redirect
        apache::vhost { "ssl-${value['bron']}":
          ensure          => $value['provision'],
          servername      => $value['bron'],
          port            => $ports['https'],
          docroot         => "${forward_docroot}/${value['bron']}",
          directories     => {
            path    => "${forward_docroot}/${value['bron']}",
            headers => [
              "always set Strict-Transport-Security \"max-age=2592000; preload\"",
              "always set Content-Security-Policy \"default-src 'self'; script-src 'none'; frame-src \'none\';\"",
              "always append X-Frame-Options SAMEORIGIN",
              "always set X-Content-Type-Options nosniff",
              "always set Referrer-Policy same-origin",
              "always set Expect-CT \"enforce, max-age=300\""
              ],
            options => '-Indexes +FollowSymLinks +MultiViews',
          },

          ssl             => true,
          ssl_cert        => "${letsencryptdir}/${value['bron']}/fullchain.pem",
          ssl_key         => "${letsencryptdir}/${value['bron']}/privkey.pem",
          protocols       => ['h2','http/1.1'],
          redirect_status => 'permanent',
          redirect_dest   => "https://${value['doel']}",
          manage_docroot  => false,
          require         => Letsencrypt::Certonly[$value['bron']],
        }

      }

      # See if forward is a frameforward
      else {
        # The SSL virtual host at the same domain frameforward
        apache::vhost { "ssl-${value['bron']}":
          ensure         => $value['provision'],
          servername     => $value['bron'],
          port           => $ports['https'],
          docroot        => "${forward_docroot}/${value['bron']}",
          directories    => {
            path    => "${forward_docroot}/${value['bron']}",
            headers => [
              "always set Strict-Transport-Security \"max-age=2592000; preload\"",
              "set Content-Security-Policy \"default-src 'self' 'unsafe-inline'; script-src 'none'; child-src https://${value['doel']}/;\"",
              "always append X-Frame-Options SAMEORIGIN",
              "always set X-Content-Type-Options nosniff",
              "always set Referrer-Policy same-origin",
              "always set Expect-CT \"enforce, max-age=300\""
              ],
            options => '-Indexes +FollowSymLinks +MultiViews',
          },

          ssl            => true,
          ssl_cert       => "${letsencryptdir}/${value['bron']}/fullchain.pem",
          ssl_key        => "${letsencryptdir}/${value['bron']}/privkey.pem",
          protocols      => ['h2','http/1.1'],
          manage_docroot => false,
          require        => Letsencrypt::Certonly[$value['bron']],
        }

      }

    }

  }

}
