# Guide: https://training.galaxyproject.org/training-material/topics/admin/tutorials/terraform/tutorial.html#citing-this-tutorial

resource "openstack_compute_keypair_v2" "my-cloud-key" { # Needs to be changed 
  name       = "project_QTL"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkuTihVgQNCf4rZPECy9KsTkO0DCcgJJUZX1IrYxww4fvaZFrafPd49UDvGlPDGHnvMdKdBXBBxNaU9Hr5jAfAJ209GhUtxaiI/uoEJxTyhYPWJoc+JVVtEZn0ixN5rxSWrz+u0XV/RRXpW1Pud5UVU7ZPJaENSzFCtxePJHNqZcp7lb50mcikI1vbfsa07g/7JG6QD4tzHt8lvnpO3K/liMXfqL5d/v9RB7Oiyyr2/FLjsPrjcW+43VRPvKVK4BhgUfZs/kJBXYIecnhbb2V6MidZEzg192iDGY6cgz8fCs37aYLZG0v6fP0Oxz4hEbxi+EXy534buU615VJiYg25 Generated-by-Nova"
}

# resource "openstack_compute_instance_v2" "ansible_master" {
#   name            = "ansible_master-vm"
#   image_name      = "Ubuntu 18.04"
#   flavor_name     = "ssc.large"
#   key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
#   security_groups = ["default"]

#   network {
#     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
#   }
# }

# resource "openstack_compute_instance_v2" "spark_master" {
#   name            = "spark_master-vm"
#   image_name      = "Ubuntu 18.04"
#   flavor_name     = "ssc.large"
#   key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
#   security_groups = ["default"]

#   network {
#     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
#   }
# }

# resource "openstack_compute_instance_v2" "spark_worker" {
#   name            = "spark_worker-${count.index}"
#   image_name      = "Ubuntu 18.04"
#   flavor_name     = "ssc.large"
#   key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
#   security_groups = ["default"]
#   count           = 2       # Should be changed according to user input from interface

#   network {
#     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
#   }
# }