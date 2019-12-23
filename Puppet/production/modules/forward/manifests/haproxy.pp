# Setup HAproxy on loadbalancers
#
# @param listenports
# Specify the hash of ports to listen on. Default: { 'http' => '80', 'https' => '443', 'api' => '5000' }
#
# @param listenip
# Specify the ip that will be used to listen to.
#
# @param listenmode
# Specify the mode of HAProxy 'tcp' or 'http'.
#
class forward::haproxy (
  $listenports = { 'http' => '80', 'https' => '443', 'api' => '5000' },
  $listenip    = '10.0.1.254',
  $listenmode  = 'tcp',
  ) {
  # Install Haproxy on loadbalancers
  include ::haproxy

  # Create a listen service for the forwardcluster no-ssl
  haproxy::listen { 'WebclusterNoSSL':
    ipaddress => $listenip,
    ports     => $listenports['http'],
    options   => {
      'mode' => $listenmode,
    },
  }

  # Create a listen service for the forwardcluster ssl
  haproxy::listen { 'WebclusterSSL':
    ipaddress => $listenip,
    ports     => $listenports['https'],
    options   => {
      'mode' => $listenmode,
    },
  }

  # Create a listen service for the apicluster
  haproxy::listen { 'API':
    ipaddress => $listenip,
    ports     => $listenports['api'],
    options   => {
      'mode' => $listenmode,
    },
  }

  #Pull all configdata from forward and apiservers out of puppetdb
  Haproxy::Balancermember <| listening_service == 'WebclusterNoSSL' |>
  Haproxy::Balancermember <| listening_service == 'WebclusterSSL' |>
  Haproxy::Balancermember <| listening_service == 'API' |>
}
