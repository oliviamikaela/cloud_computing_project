terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "keypairQTL"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkuTihVgQNCf4rZPECy9KsTkO0DCcgJJUZX1IrYxww4fvaZFrafPd49UDvGlPDGHnvMdKdBXBBxNaU9Hr5jAfAJ209GhUtxaiI/uoEJxTyhYPWJoc+JVVtEZn0ixN5rxSWrz+u0XV/RRXpW1Pud5UVU7ZPJaENSzFCtxePJHNqZcp7lb50mcikI1vbfsa07g/7JG6QD4tzHt8lvnpO3K/liMXfqL5d/v9RB7Oiyyr2/FLjsPrjcW+43VRPvKVK4BhgUfZs/kJBXYIecnhbb2V6MidZEzg192iDGY6cgz8fCs37aYLZG0v6fP0Oxz4hEbxi+EXy534buU615VJiYg25 Generated-by-Nova"
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
   name            = "sparkworker${count.index}"
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

      
resource "null_resource" "provision0" {

  depends_on = ["openstack_compute_floatingip_associate_v2.floatip_1","openstack_compute_floatingip_associate_v2.floatip_2","openstack_compute_floatingip_associate_v2.floatip_3"]
  triggers = {
    ansible_master_id = "${openstack_compute_floatingip_associate_v2.floatip_1.id}"
    spark_master_id = "${openstack_compute_floatingip_associate_v2.floatip_2.id}"
    spark_worker_id = "${element(openstack_compute_floatingip_associate_v2.floatip_3.*.id, (var.num_workers - 1))}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("project_QTL.pem")}" 
    host        = openstack_networking_floatingip_v2.floatip_1.address
  }
  provisioner "file" {
    source = "../ansible_install.sh"
    destination = "ansible_install.sh"
  }
  provisioner "file" {
    source = "../setup_var.yml"
    destination = "setup_var.yml"
  }
  provisioner "file" {
    source = "../spark_deployment.yml"
    destination = "spark_deployment.yml"
  }
  provisioner "file" {
    source = "add_ansible_hosts"
    destination = "add_ansible_hosts"
  }
  provisioner "file" {
    source = "project_QTL.pem"
    destination = "project_QTL.pem"
  }
  provisioner "file" {
    source = "etc_hosts"
    destination = "etc_hosts"
  }
  provisioner "remote-exec" {
    inline = [
      "mv -f project_QTL.pem ~/.ssh/project_QTL.pem",
      "echo nu borjas det!",
      "for i in {1..7}; do echo $i; done",
      "chmod 400 ~/.ssh/project_QTL.pem",
      "echo 'Y' | sudo bash ansible_install.sh",
      "cd ~",
      "sudo -- sh -c 'cat /home/ubuntu/etc_hosts > /etc/hosts'",
      "sudo -- sh -c 'echo ${openstack_networking_floatingip_v2.floatip_1.address} ansible-node >> /etc/hosts'",
      "sudo -- sh -c 'echo ${openstack_networking_floatingip_v2.floatip_2.address} sparkmaster >> /etc/hosts'",
      "echo 'n' | ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''",
      "cp ~/.ssh/authorized_keys authorized_keys",
      "cat ~/.ssh/id_rsa.pub >> authorized_keys",
      "ssh-keygen -R ${openstack_networking_floatingip_v2.floatip_2.address}",
      "sleep 30",
      "scp -o 'StrictHostKeyChecking=no' -i ~/.ssh/project_QTL.pem authorized_keys ubuntu@${openstack_networking_floatingip_v2.floatip_2.address}:~/.ssh/authorized_keys",
      "sudo -- sh -c 'echo ansible-node ansible_ssh_host=${openstack_networking_floatingip_v2.floatip_1.address} > /etc/ansible/hosts'",
      "sudo -- sh -c 'echo sparkmaster  ansible_ssh_host=${openstack_networking_floatingip_v2.floatip_2.address} >> /etc/ansible/hosts'",
     ]
  }
}

resource "null_resource" "provision1" {
  count = var.num_workers
  depends_on = ["openstack_compute_floatingip_associate_v2.floatip_1","openstack_compute_floatingip_associate_v2.floatip_2","openstack_compute_floatingip_associate_v2.floatip_3", "null_resource.provision0"]
  triggers = {
    ansible_master_id = "${openstack_compute_floatingip_associate_v2.floatip_1.id}"
    spark_master_id = "${openstack_compute_floatingip_associate_v2.floatip_2.id}"
    spark_worker_id = "${element(openstack_compute_floatingip_associate_v2.floatip_3.*.id, (var.num_workers - 1))}"
    provision_0 = "${null_resource.provision0.id}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("project_QTL.pem")}"
    host        = openstack_networking_floatingip_v2.floatip_1.address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'saving to host: ${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)} ${element(openstack_compute_instance_v2.worker.*.name, count.index)} '",
      "sudo -- sh -c 'echo ${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)} ${element(openstack_compute_instance_v2.worker.*.name, count.index)} >> /etc/hosts'",  
      "ssh-keygen -R ${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)}",
      "sleep 30",
      "scp -o 'StrictHostKeyChecking=no' -i ~/.ssh/project_QTL.pem authorized_keys ubuntu@${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)}:~/.ssh/authorized_keys", 
      "sudo -- sh -c 'echo ${element(openstack_compute_instance_v2.worker.*.name, count.index)} ansible_ssh_host=${element(openstack_networking_floatingip_v2.floatip_3.*.address, count.index)} >> /etc/ansible/hosts'", 
     ]
  }
}

resource "null_resource" "provision2" {

  depends_on = ["openstack_compute_floatingip_associate_v2.floatip_1","openstack_compute_floatingip_associate_v2.floatip_2","openstack_compute_floatingip_associate_v2.floatip_3", "null_resource.provision1"]
  triggers = {
    ansible_master_id = "${openstack_compute_floatingip_associate_v2.floatip_1.id}"
    spark_master_id = "${openstack_compute_floatingip_associate_v2.floatip_2.id}"
    spark_worker_id = "${element(openstack_compute_floatingip_associate_v2.floatip_3.*.id, (var.num_workers - 1))}"
    provision_1 = "${element(null_resource.provision1.*.id, (var.num_workers - 1))}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("project_QTL.pem")}" 
    host        = openstack_networking_floatingip_v2.floatip_1.address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'cat /home/ubuntu/add_ansible_hosts >> /etc/ansible/hosts'",
      "sudo -- sh -c 'echo sparkworker[0:$((${var.num_workers}-1))] ansible_connection=ssh ansible_user=ubuntu >> /etc/ansible/hosts'", 
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -b spark_deployment.yml > output_QTL.txt",
      "grep 'token' output_QTL.txt > login_info.txt",
      "echo ${openstack_networking_floatingip_v2.floatip_2.address} >> login_info.txt"
     ]
  }

  provisioner "local-exec" {
    command = "sudo scp -o StrictHostKeyChecking=no -i project_QTL.pem ubuntu@${openstack_networking_floatingip_v2.floatip_1.address}:login_info.txt login_info.txt"
  }
}
