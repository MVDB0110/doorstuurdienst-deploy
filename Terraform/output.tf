# // Output Section
output "webcluster_ip" {
  value       = openstack_networking_floatingip_v2.external_load_fip.address
  description = "IP to connect to the webcluster"
}

output "manage_ip" {
  value       = openstack_networking_floatingip_v2.external_master_fip.address
  description = "IP to connect to the Puppet Master"
}

output "api_ip" {
  value       = openstack_networking_port_v2.api_port[*].fixed_ip[0].ip_address
  description = "IP to connect to the API node"
}

output "loadbalancer_ip" {
  value       = openstack_networking_port_v2.loadbalancer_port[*].all_fixed_ips
  description = "IP to connect to the API node"
}

output "forwardservers_ip" {
  value       = openstack_networking_port_v2.forwardserver_port[*].all_fixed_ips
  description = "IP to connect to the API node"
}

output "nms_ip" {
  value       = openstack_networking_floatingip_v2.external_nms_fip.address
  description = "IP to connect to the NMS node"
}
# \\
