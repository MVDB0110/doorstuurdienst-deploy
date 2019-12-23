# // Security Section
resource "openstack_networking_secgroup_v2" "webservice" {
  name        = "webservice"
  description = "Webservice Security Group"
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_vrrp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "112"
  remote_ip_prefix  = "10.0.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8140
  port_range_max    = 8140
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_7" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 111
  port_range_max    = 111
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_8" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 54302
  port_range_max    = 54302
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_9" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 20048
  port_range_max    = 20048
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_10" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2049
  port_range_max    = 2049
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}
resource "openstack_networking_secgroup_rule_v2" "webservice_rule_11" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 42955
  port_range_max    = 42955
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}
resource "openstack_networking_secgroup_rule_v2" "webservice_rule_12" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 46666
  port_range_max    = 46666
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_13" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 875
  port_range_max    = 875
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_14" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10050
  port_range_max    = 10050
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_15" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10051
  port_range_max    = 10051
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_16" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3000
  port_range_max    = 3000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_17" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8086
  port_range_max    = 8086
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}

resource "openstack_networking_secgroup_rule_v2" "webservice_rule_18" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8088
  port_range_max    = 8088
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.webservice.id
}
# \\
