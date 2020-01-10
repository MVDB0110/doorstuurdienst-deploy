# // Provider Section
provider "openstack" {
  user_name = "mvandenbrink"
  password  = "*****"
  auth_url = "https://keystone.openstack.eq.hostnetbv.nl:5000/v3"
  user_domain_name = "Default"
}
# \\

# // Network Section
resource "openstack_networking_router_v2" "domain_r" {
  name                = "neutron"
  admin_state_up      = "true"
  external_network_id = "878dc736-dabe-4674-a2fb-3cd7673071df"
}

resource "openstack_networking_network_v2" "service_n" {
  name                = "service"
  admin_state_up      = "true"
}

resource "openstack_networking_network_v2" "management_n" {
  name           = "management"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "loadbalancer_n" {
  name           = "loadbalancer"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "service_s" {
  name            = "service"
  network_id      = openstack_networking_network_v2.service_n.id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  gateway_ip      = "10.0.0.1"
  dns_nameservers = ["10.0.2.254","1.1.1.1"]
  enable_dhcp     = true

  allocation_pool {
    start         = "10.0.0.128"
    end           = "10.0.0.254"
  }
}

resource "openstack_networking_subnet_v2" "management_s" {
  name            = "management"
  network_id      = openstack_networking_network_v2.management_n.id
  cidr            = "10.0.2.0/24"
  ip_version      = 4
  gateway_ip      = "10.0.2.1"
  dns_nameservers = ["10.0.2.254","1.1.1.1"]
  enable_dhcp     = true

  allocation_pool {
    start         = "10.0.2.128"
    end           = "10.0.2.254"
  }
}

resource "openstack_networking_subnet_v2" "loadbalancer_s" {
  name            = "loadbalancer"
  network_id      = openstack_networking_network_v2.loadbalancer_n.id
  cidr            = "10.0.1.0/24"
  ip_version      = 4
  gateway_ip      = "10.0.1.1"
  dns_nameservers = ["10.0.2.254","1.1.1.1"]
  enable_dhcp     = true

  allocation_pool {
    start         = "10.0.1.128"
    end           = "10.0.1.254"
  }
}

resource "openstack_networking_router_interface_v2" "service_i" {
  router_id = openstack_networking_router_v2.domain_r.id
  subnet_id = openstack_networking_subnet_v2.service_s.id
}

resource "openstack_networking_router_interface_v2" "management_i" {
  router_id = openstack_networking_router_v2.domain_r.id
  subnet_id = openstack_networking_subnet_v2.management_s.id
}

resource "openstack_networking_router_interface_v2" "loadbalancer_i" {
  router_id = openstack_networking_router_v2.domain_r.id
  subnet_id = openstack_networking_subnet_v2.loadbalancer_s.id
}
# \\
