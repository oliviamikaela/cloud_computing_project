resource "openstack_compute_keypair_v2" "my-cloud-key" { # Needs to be changed 
  name       = "my-key"
  public_key = "ssh-rsa AAAAB3Nz..."
}

resource "openstack_compute_instance_v2" "ansible_master" {
  name            = "ansible_master-vm"
  image_name      = "Ubuntu 18.04"
  flavor_name     = "ssc.large"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = ["default"]

  network {
    name = "UPPMAX 2021/1-5 Internal IPv4 Network"
  }
}

resource "openstack_compute_instance_v2" "spark_master" {
  name            = "spark_master-vm"
  image_name      = "Ubuntu 18.04"
  flavor_name     = "ssc.large"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = ["default"]

  network {
    name = "UPPMAX 2021/1-5 Internal IPv4 Network"
  }
}

resource "openstack_compute_instance_v2" "spark_worker" {
  name            = "spark_worker-${count.index}"
  image_name      = "Ubuntu 18.04"
  flavor_name     = "ssc.large"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = ["default"]
  count           = 2       # Should be changed according to user input from interface

  network {
    name = "UPPMAX 2021/1-5 Internal IPv4 Network"
  }
}