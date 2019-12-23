# // Port Section
resource "openstack_networking_port_v2" "loadbalancer_vrrp" {
  name               = "LoadbalancerVRRP"
  network_id         = openstack_networking_network_v2.loadbalancer_n.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.webservice.id]
  fixed_ip {
    subnet_id        = openstack_networking_subnet_v2.loadbalancer_s.id
    ip_address       = "10.0.1.254"
  }
}

resource "openstack_networking_port_v2" "loadbalancer_port" {
  name               = "LoadbalancerPort${count.index}"
  network_id         = openstack_networking_network_v2.loadbalancer_n.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.webservice.id]
  allowed_address_pairs {
    ip_address       = "10.0.1.254"
  }
  fixed_ip {
    subnet_id        = openstack_networking_subnet_v2.loadbalancer_s.id
  }
  count              = var.counts["loadbalancer"]
}

resource "openstack_networking_port_v2" "forwardserver_port" {
  name               = "ForwardserverPort${count.index}"
  network_id         = openstack_networking_network_v2.service_n.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.webservice.id]
  fixed_ip {
    subnet_id        = openstack_networking_subnet_v2.service_s.id
  }
  count              = var.counts["forwardserver"]
}

resource "openstack_networking_port_v2" "api_port" {
  name               = "APIPort${count.index}"
  network_id         = openstack_networking_network_v2.service_n.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.webservice.id]
  fixed_ip {
    subnet_id        = openstack_networking_subnet_v2.service_s.id
    ip_address       = "10.0.0.254"
  }
  count              = var.counts["api"]
}
# \\
