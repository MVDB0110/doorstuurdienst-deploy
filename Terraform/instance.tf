# // Instance Section
resource "openstack_compute_instance_v2" "master" {
  name                = "HN-FWPS-0"
  image_name          = "centos-7-1907"
  flavor_name         = "HN-2CPU-4096MiB"
  security_groups     = [openstack_networking_secgroup_v2.webservice.name]
  stop_before_destroy = true
  user_data           = file("master.conf")

  block_device {
    uuid                  = "1e2856f9-2a39-4822-823b-af714384e4d4"
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name        = openstack_networking_network_v2.management_n.name
    fixed_ip_v4 = "10.0.2.254"
  }

  depends_on = [openstack_networking_subnet_v2.management_s]
}

resource "openstack_compute_instance_v2" "nms" {
  name                = "HN-FWNM-0"
  image_name          = "ubuntu-1804_2019-11-25_17:28:08"
  flavor_name         = "HN-1CPU-1024MiB"
  security_groups     = [openstack_networking_secgroup_v2.webservice.name]
  stop_before_destroy = true
  user_data           = file("nms.conf")

  block_device {
    uuid                  = "8a69e8b9-1873-4411-ba31-24785813407c"
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name        = openstack_networking_network_v2.management_n.name
    fixed_ip_v4 = "10.0.2.253"
  }

  depends_on = [openstack_networking_subnet_v2.management_s]
}

resource "openstack_compute_instance_v2" "forwardserver" {
  name                = "HN-FWWE-${count.index}"
  image_name          = "ubuntu-1804_2019-11-25_17:28:08"
  flavor_name         = "HN-1CPU-1024MiB"
  security_groups     = [openstack_networking_secgroup_v2.webservice.name]
  stop_before_destroy = true
  user_data           = file("forwardservers.conf")
  count               = var.counts["forwardserver"]

  block_device {
    uuid                  = "8a69e8b9-1873-4411-ba31-24785813407c"
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.forwardserver_port[count.index].id
  }
}

resource "openstack_compute_instance_v2" "loadbalancer" {
  name                = "HN-FWLO-${count.index}"
  image_name          = "centos-7-1907"
  availability_zone   = "AMS1"
  flavor_name         = "HN-1CPU-1024MiB"
  security_groups     = [openstack_networking_secgroup_v2.webservice.name]
  stop_before_destroy = true
  user_data           = file("agents.conf")
  count               = var.counts["loadbalancer"]

  block_device {
    uuid                  = "1e2856f9-2a39-4822-823b-af714384e4d4"
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.loadbalancer_port[count.index].id
  }
}

resource "openstack_compute_instance_v2" "api" {
  name                = "HN-FWAP-${count.index}"
  image_name          = "centos-7-1907"
  availability_zone   = "AMS1"
  flavor_name         = "HN-1CPU-1024MiB"
  security_groups     = [openstack_networking_secgroup_v2.webservice.name]
  stop_before_destroy = true
  user_data           = file("api.conf")
  count               = var.counts["api"]

  block_device {
    uuid                  = "1e2856f9-2a39-4822-823b-af714384e4d4"
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.api_port[count.index].id
  }
}
# \\
