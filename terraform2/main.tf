# This was not in the guide. Is needed
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}


resource "openstack_compute_instance_v2" "ansible_master" {
   name            = "ansible_master-vm"
   image_id = "0b7f5fb5-a25c-48b6-8578-06dbfa160723"
   flavor_name     = "ssc.large"
   security_groups = ["default"]
   network {
     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
   }
 }