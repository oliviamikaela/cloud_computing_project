# This was not in the guide. Is needed
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}
#public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnUaJC9yNb/Whhfj4g7ttPygPOwEEAtNRDSctmT++mptYBNJx30qZG83IAfzhoKjSQMJSUEtDalSYWqVlonJfa9nDmFwvhgxVy2FUrS1KwtZafU69j2kwva/ifHz0EIXePCwrP+sDZyaLLfnsfAabtE1lCesC/0t8PyrfIWi8XLA+BU7O+uFEsqfL1gILv0TQl+iA5kk4b6UdMWJu3wlobkqSX/2/rPuipXiG8Mxum3dMuEL2cYwJxF3KmyK/gc8es3ObPVK4hiAuDpy53a5fi9yIZsneH6W8d4Orkja7Aj06nNtf4r53RfdGVYzTa6Z2q+ofyDCHc3XstLjBQpt/qrswoKZvVB2C7UbazYuZCqhooQaEwpyAxwBUobzz4Sl+Z6Miu8TotGkSqVV+zbVJYPNG2yMHlWO+y9IxCpRVxUy5ZwxzuwTOruVYTmKM++vZRZtcFdj9oGeWQOqM1laU8kKTPi+Z7QOpslpF4K+80WATYh1jKIjDPlYSanyklomHrTSc9C0qshXgbyYySfnNEvvNqPYGDhpVs7B/iWP4N7tOPGVOBx/5dKxHIb+V86PUqxxwf9qeidtAja5iZ6SykLAYKZqOz6Mlihw6NJ36nbSSYug1APAvT7rpNi+hH3fkWUWHPz0pBKo6VQw8a2mDEj+XzHnfOyl03NmAb3aGU2w== ammaraldhahyani@student-215-91.eduroam.uu.se"

resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "keypairQTL"
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "Public External IPv4 Network"
}

resource "openstack_networking_floatingip_v2" "floatip_2" {
  pool = "Public External IPv4 Network"
}

resource "openstack_networking_floatingip_v2" "floatip_3" {
  pool = "Public External IPv4 Network"
  count = var.num_workers
}



resource "openstack_compute_instance_v2" "ansible_master" {
   name            = "ansible_master-vm"
   image_id = "0b7f5fb5-a25c-48b6-8578-06dbfa160723"
   flavor_name     = "ssc.large"
   key_pair = "keypairQTL"
   security_groups = ["default"]
   network {
     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
   }
 }

 resource "openstack_compute_instance_v2" "spark_master" {
   name            = "spark_master-vm"
   image_id = "0b7f5fb5-a25c-48b6-8578-06dbfa160723"
   flavor_name     = "ssc.large"
   key_pair = "keypairQTL"
   security_groups = ["default"]
   network {
     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
   }
 }

 resource "openstack_compute_instance_v2" "worker" {
   name            = "worker-vm"
   count = var.num_workers
   image_id = "0b7f5fb5-a25c-48b6-8578-06dbfa160723"
   flavor_name     = "ssc.large"
   key_pair = "keypairQTL"
   security_groups = ["default"]
   network {
     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
   }
 }


 resource "openstack_compute_floatingip_associate_v2" "floatip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
  instance_id = "${openstack_compute_instance_v2.ansible_master.id}"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_2" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_2.address}"
  instance_id = "${openstack_compute_instance_v2.spark_master.id}"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_3" {
  count = var.num_workers
  floating_ip = "${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.worker.*.id, count.index)}"
  
}