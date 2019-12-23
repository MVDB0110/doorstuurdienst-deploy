# // Floating IP Section
resource "openstack_networking_floatingip_v2" "external_master_fip" {
  description = "External IP for Puppet Master"
  pool = "hostnet-external-2626"
}

resource "openstack_compute_floatingip_associate_v2" "external_master" {
  floating_ip = openstack_networking_floatingip_v2.external_master_fip.address
  instance_id = openstack_compute_instance_v2.master.id
  fixed_ip    = openstack_compute_instance_v2.master.network.0.fixed_ip_v4
}

resource "openstack_networking_floatingip_v2" "external_nms_fip" {
  description = "External IP for Network Monitoring Server"
  pool = "hostnet-external-2626"
}

resource "openstack_compute_floatingip_associate_v2" "external_nms" {
  floating_ip = openstack_networking_floatingip_v2.external_nms_fip.address
  instance_id = openstack_compute_instance_v2.nms.id
  fixed_ip    = openstack_compute_instance_v2.nms.network.0.fixed_ip_v4
}

resource "openstack_networking_floatingip_v2" "external_load_fip" {
  description = "External Webcluster IP"
  pool = "hostnet-external-2626"
  port_id = openstack_networking_port_v2.loadbalancer_vrrp.id
}
# \\
