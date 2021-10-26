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

# data "template_file" "user_data" {
#   template = templatefile(
#     "config-ansible_master.yml", 
#     {
#       num_workers = ${var.num_workers},
#       ansible_floating_ip = ${openstack_networking_floatingip_v2.floatip_1.address},
#       spark_master_private_ip = ${openstack_compute_instance_v2.spark_master.access_ip_v4},
#       spark_worker_private_ip = ${openstack_compute_instance_v2.worker.0.access_ip_v4} # Needs to be changed so it works for all worker nodes
#     })

# }

# locals {
#   vars = {
#       num_workers = "${var.num_workers}",
#       ansible_floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}",
#       spark_master_private_ip = "${openstack_compute_instance_v2.spark_master.access_ip_v4}",
#       spark_worker_private_ip = "${openstack_compute_instance_v2.worker.0.access_ip_v4}" # Needs to be changed so it works for all worker nodes
#     }
# }

resource "openstack_compute_instance_v2" "ansible_master" {
   name            = "ansible_master-vm"
   image_id = "0b7f5fb5-a25c-48b6-8578-06dbfa160723"
   flavor_name     = "ssc.large"
   key_pair = "keypairQTL"
   security_groups = ["default"]
   network {
     name = "UPPMAX 2021/1-5 Internal IPv4 Network"
   }
   user_data = templatefile("config-ansible_master.yml", {
      num_workers = var.num_workers,
      ansible_floating_ip = openstack_networking_floatingip_v2.floatip_1.address,
      spark_master_private_ip = openstack_compute_instance_v2.spark_master.access_ip_v4,
      spark_worker_private_ip = openstack_compute_instance_v2.worker.0.access_ip_v4 # Needs to be changed so it works for all worker nodes
    })
   #user_data = data.template_file.user_data.rendered
#  #user_data = <<-EOF
  #   #cloud-config
  #   write_files:
  #     - path: /home/ubuntu/spark_deploymen.yml
  #       content: |
  #         - hosts: all
  #           tasks:

  #           - name: Generate hosts file
  #             lineinfile: dest=/etc/hosts
  #                         regexp='.*{{ item }}$'
  #                         line="{{ hostvars[item].ansible_default_ipv4.address }} {{item}}"
  #                         state=present            
  #             when: hostvars[item].ansible_default_ipv4.address is defined
  #             with_items: "{{groups['all']}}"
            
  #           - name: Set hostname
  #             hostname: name="{{inventory_hostname}}"
            
  #           - name: Include variables
  #             include_vars: setup_var.yml 

  #           - name: apt update
  #             apt: update_cache=yes upgrade=dist

  #           - name: install java
  #             apt: pkg={{item}} state=latest update_cache=true 
  #             with_items:
  #             - default-jre
  #             - default-jdk
  #               - openjdk-8-jdk
  #               - openjdk-8-jre   
  #           - name: download spark
  #             unarchive: src={{item}} dest=/usr/local/ copy=no 
  #             with_items: "{{spark_urls}}"  
              
  #             unarchive: src={{item}} dest=/usr/local/ copy=no
  #             with_items:
  #             - http://apache.mirrors.spacedump.net/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz
  #             - http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz

  #           - name: adding paths
  #             lineinfile: dest="{{rc_file}}" line='export PATH=$PATH:{{spark_home}}/bin/:{{scala_home}}/bin\nexport JAVA_HOME={{java_home}}\nSPARK_HOME={{spark_home}}' insertafter='EOF' regexp='export PATH=\$SPARK_HOME' state=present 

  #             lineinfile: dest=/home/ubuntu/.bashrc line='export PATH=$PATH:/usr/local/spark-1.6.1-bin-hadoop2.6/bin/:/usr/local/scala-2.11.8/bin\nexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\nSPARK_HOME=/usr/local/spark-1.6.1-bin-hadoop2.6' insertafter='EOF' regexp='export PATH=\$SPARK_HOME' state=present 
            
  #           - name: source bashrc   
  #             shell: . "{{rc_file}}"

  #           - name: R repo key
  #             apt_key: keyserver=keyserver.ubuntu.com id=E298A3A825C0D65DFD57CBB651716619E084DAB9
  #             keyserver.ubuntu.com

  #           - name: adding R repo
  #             apt_repository: repo={{r_repo}} update_cache=yes
  #             apt_repository: repo='deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu bionic-cran35/' update_cache=yes 
  #             deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu xenial/
  #             apt_repository: repo={{r_repo}} update_cache=yes

  #             apt_repository: repo='deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu trusty/' update_cache=yes
          
  #           - name: apt update
  #             apt: update_cache=yes upgrade=dist

  #           - name: install R 
  #             apt: pkg={{item}} state=latest update_cache=true allow_unauthenticated=yes 
  #             with_items:
  #               - r-base
  #               - r-base-dev
  #               - libxml2-dev

  #           - name: adding extra repo
  #             apt_repository: repo={{r_repo}} update_cache=yes
  #             apt_repository: repo='ppa:marutter/c2d4u3.5/ubuntu' update_cache=yes 

  #           - name: extra packages
  #             apt: pkg={{item}} state=latest update_cache=true allow_unauthenticated=yes
  #             with_items: 
  #               - libreadline-dev
  #               - libzmq5 
  #               - libzmq5-dev
  #               - libcurl4-gnutls-dev
  #               - r-cran-rcurl
  #               - libssl-dev

  #           - name: R lib instalation
  #             command: Rscript --slave --no-save --no-restore-history -e "if (! ('{{ item }}' %in% installed.packages()[,'Package'])) { install.packages(pkgs='{{ item }}', repos=c('https://cran.rstudio.com')); print('Added'); } else { print('Already installed'); }"
  #             register: r_result
  #             failed_when: "r_result.rc != 0 or 'had non-zero exit status' in r_result.stderr"
  #             changed_when: "'Added' in r_result.stdout"
  #             with_items:
  #               - RCurl
  #               - openssl
  #               - httr
  #               - git2r
  #               - libxml2-dev
  #               - roxygen2
  #               - rversions
  #               - devtools
  #               - evaluate 
  #               - jsonlite
  #               - digest
  #               - base64enc
  #               - uuid 
  #               - qtl

  #           - name: R  spark integration
  #             command: Rscript --slave --no-save --no-restore-history -e "if (! ('{{ item }}' %in% installed.packages()[,'Package'])) { install.packages(pkgs='{{ item }}', repos=c('http://irkernel.github.io/'), type = 'source'); print('Added'); } else { print('Already installed'); }"
  #             register: r_result
  #             failed_when: "r_result.rc != 0 or 'had non-zero exit status' in r_result.stderr"
  #             changed_when: "'Added' in r_result.stdout"
  #             with_items:
  #               - rzmq
  #               - repr
  #               - evaluate
  #               - crayon
  #               - pbdZMQ
  #               - devtools
  #               - uuid
  #               - digest
  #               - IRkernel
  #               - IRdisplay

  #         - hosts: sparkmaster
            
  #           vars_files:
  #           - setup_var.yml  

  #           tasks: 
  #           - name: install jupyter
  #             apt: pkg={{item}} state=latest update_cache=true
  #             with_items:
  #               - python3-pip
  #               - python-dev
  #               - build-essential
  #               - python-setuptools
  #           - pip: name=pip state=latest

  #           - pip: name=jupyter state=present
              
  #           - name: adding paths
  #             lineinfile: dest={{rc_file}} line='export JUPYTER_CONFIG_DIR={{jupyter_config_dir}}\n export JUPYTER_PATH={{jupyter_path}}\nexport JUPYTER_RUNTIME_DIR={{jupyter_runtime_dir}}' insertafter='EOF' regexp='export JUPYTER_PATH' state=present 

  #             lineinfile: dest=/home/ubuntu/.bashrc line='export JUPYTER_CONFIG_DIR=/usr/local/etc/jupyter\n export JUPYTER_PATH=/usr/local/share/jupyter\nexport JUPYTER_RUNTIME_DIR=/usr/local/share/jupyter-runtime' insertafter='EOF' regexp='export PATH=\$SPARK_HOME' state=present 
            
  #           - name: source bashrc   
  #             shell: . {{rc_file}}

  #             shell: . /home/ubuntu/.bashrc

  #           - name:  add IRKernel
  #             command: /usr/bin/Rscript --slave --no-save --no-restore-history -e "devtools::install_github('IRkernel/IRkernel')"

  #           - name: start IRKernel
  #             command: /usr/bin/Rscript --slave --no-save --no-restore-history -e "IRkernel::installspec(user = FALSE)"

  #           - name: start jupyter
  #             shell: runuser -l ubuntu -c 'jupyter notebook --ip=0.0.0.0 --port=60060 &'
  #             async: 2592000               # 60*60*24*30 – 1 month
  #             args:
  #               executable: /bin/bash 
            
  #           - name: jupyter server token
  #             shell: cat /home/ubuntu/.local/share/jupyter/runtime/*.json | grep token 
  #             register: token

  #           - debug:
  #               var: token.stdout_lines
            
  #           - name: disable IPv6
  #             shell: "{{item}}"
  #             with_items: 
  #               - echo "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  #               - sysctl -p

  #           - name: start spark master process
  #             shell: nohup {{spark_home}}/sbin/start-master.sh  &

  #         - hosts: sparkworker
              
  #           vars_files:
  #           - setup_var.yml

  #           tasks:
  #           - name: disable IPv6
  #             shell: "{{item}}"
  #             with_items:
  #               - echo "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  #               - sysctl -p
          
  #           - name: start spark worker process
  #             shell: nohup {{spark_home}}/sbin/start-slave.sh spark://sparkmaster:7077 &
  #     - path: /home/ubuntu/setup_var.yaml
  #       content: |
  #         rc_file: /home/ubuntu/.bashrc
  #         spark_home: /usr/local/spark-2.4.7-bin-hadoop2.7
  #         scala_home: /usr/local/scala-2.11.8
  #         java_home: /usr/lib/jvm/java-8-openjdk-amd64

  #         spark_urls:
  #         - https://archive.apache.org/dist/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
  #         - http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz

  #         r_repo: 'deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu bionic-cran35/'

  #         jupyter_path: /usr/local/share/jupyter
  #         jupyter_runtime_dir: /usr/local/share/jupyter-runtime
  #         jupyter_config_dir: /usr/local/etc/jupyter
  #     - path: /home/ubuntu/ansible_install.sh
  #       content: |
  #         !/bin/bash 

  #         # Installing Ansible 

  #         sudo apt-add-repository -y ppa:ansible/ansible
  #         sudo apt-get update
  #         sudo apt-get upgrade
  #         sudo apt-get install -y ansible

  #         #####################
  #     - path: /home/ubuntu/add_ansible_hosts
  #       content: |

  #         [configNode]
  #         ansible-node ansible_connection=local ansible_user=ubuntu

  #         [sparkmaster]
  #         sparkmaster ansible_connection=ssh ansible_user=ubuntu

  #         [sparkworker]
  #         sparkworker[1:${var.num_workers}] ansible_connection=ssh ansible_user=ubuntu # Add variable that specifyen number of workers
  #     - path: /home/ubuntu/hugo-key.pem
  #       content: |
  #         -----BEGIN RSA PRIVATE KEY-----
  #         MIIEpQIBAAKCAQEA25P0Tjhe7iJ/2THxtNe+n1EI5lCaPO520kPmtQmsVZFR59AY
  #         YtOPd7TiqOGZCPM6+mH92MSiljneA1jZzI05dW552X+xXta6OEhb3E46UwumiGQm
  #         +XlQO3HCIdDl7TLZfDItCHuJ78yi1NG0wA8Q/m2IpK8JuBRJK9QFSE6WpndlpZar
  #         hai5ORcmXIzbCTN305FZZASl9Tx3C2DlXuKw84i72dwJuJ5jXNAiGJKUNl4JwUgi
  #         OAWBSxPQAntJUKHT+9T41XPnn/DY+m6qfidHNVL/xAobG7wdnjLkDJmWcX937YsA
  #         mETWrhTyfBvj9S6ddpe5sOgwyuImMgosIiAUWQIDAQABAoIBAQCxQi2U/7jS8RLY
  #         mZMQdKI0JszScPsyeSd+8sXKHDb9FMVUKA+nqDZHYsUfpI9QRFq2SmkMlyDRuYFa
  #         nl2k3dUm0bqYNJdRgnLugKt3m8dFxz/3FzLHboGwm1MmzWbwJ36e3jqwgFqINWC2
  #         AVyzNvZ3DqGioJNuASJYuV5SUu8XDgkpg2OOztA6OGVO7OUa76VcOb+qjBLnEifF
  #         i6uiBzbxPkvVsOHJHWL4Ygi/W3p2uOyI7ggTzlV169DeA6YA8TiLw5Oa23qqzcMK
  #         0wx4VBkHbdn5KASxY9dnXfrOdfVGmgDHKD3UXONeTie6DMi5JnnFfi8YRw5ax+Hf
  #         onbZOocBAoGBAPGLwJlJ4+prUCv9jTYT3sCX4R/HKbZNsOWRy2DsSdOkaFHcvOLw
  #         HXprLxpHzXX5BuFF3ue/8ue6ksx04h2B5sW4jt1dVKpBS7AU0YdahOyr2Zmj/V0v
  #         dnUk5pdVtKrmJs56H90ivnUDMHlrq3ve523/Nv0+gi9toATBlJ2QRwtpAoGBAOi3
  #         rJuCKVLM7DDAomQ06xzs5e0euCrbK3TenFCisziupctaxI2KE+bV1Ixcr9GXrurs
  #         h3JMr635IaDS26VksBzmb8Ws/DWWbKdA9a41XtE0jygso+pddUIR5YEE+AtQH47I
  #         mt+AHk0FAxUzX17Q9jMEpCMpfLSuJF533GNcaVNxAoGBALaAfjQTxTYAgSHLwJ8k
  #         YkCoQLuO8rBAgTDjeIQx5BIZ/YwkuT7KZ6twQrWbnNzPHGinLyVxPWni6Tm78oCS
  #         /rdTm/Ybp3XAQhy3jhyzww1DRvU0F6IJ03ntOKENa6VYoeeOFHcz4i1tDHohZP8B
  #         y2Cr3XN4gEqvjKErVku6kENJAoGBALyY3hHJEqQ/3spD01dSa5gthMj+NFLG/Bji
  #         r9vJf2VYZJTBIrlyRV61vGNkWjiJrQBGYB6Jd3aOiGpFeCw5xWAmgD67SkpDdhq1
  #         0mU0a3swFTSBuPWeeADrcAt3c233qRuWB61Jr0TL4wuzbn7w6hW+lSbJ4H6tAlxs
  #         1vbPVayBAoGAAiABOovuoCmkmWDXrDLpVw+XzLay63rMAmY3Rji7KSuhGAShLuER
  #         XT34Y8ThYFZHZCinb1G1gw93px+P7AYDhS8ew42pWlGFbTBETOE0gJJfVnMXtBlg
  #         Ijn4IPICzyIkEHqjzF7VLIQ1Ca+vXpuB8GhEc8esrxg5h4Qua09C5yk=
  #         -----END RSA PRIVATE KEY-----
  #   runcmd:
  #   #- echo "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAKCAQEA25P0Tjhe7iJ/2THxtNe+n1EI5lCaPO520kPmtQmsVZFR59AY\nYtOPd7TiqOGZCPM6+mH92MSiljneA1jZzI05dW552X+xXta6OEhb3E46UwumiGQm\n+XlQO3HCIdDl7TLZfDItCHuJ78yi1NG0wA8Q/m2IpK8JuBRJK9QFSE6WpndlpZar\nhai5ORcmXIzbCTN305FZZASl9Tx3C2DlXuKw84i72dwJuJ5jXNAiGJKUNl4JwUgi\nOAWBSxPQAntJUKHT+9T41XPnn/DY+m6qfidHNVL/xAobG7wdnjLkDJmWcX937YsA\nmETWrhTyfBvj9S6ddpe5sOgwyuImMgosIiAUWQIDAQABAoIBAQCxQi2U/7jS8RLY\nmZMQdKI0JszScPsyeSd+8sXKHDb9FMVUKA+nqDZHYsUfpI9QRFq2SmkMlyDRuYFa\nnl2k3dUm0bqYNJdRgnLugKt3m8dFxz/3FzLHboGwm1MmzWbwJ36e3jqwgFqINWC2\nAVyzNvZ3DqGioJNuASJYuV5SUu8XDgkpg2OOztA6OGVO7OUa76VcOb+qjBLnEifF\ni6uiBzbxPkvVsOHJHWL4Ygi/W3p2uOyI7ggTzlV169DeA6YA8TiLw5Oa23qqzcMK\n0wx4VBkHbdn5KASxY9dnXfrOdfVGmgDHKD3UXONeTie6DMi5JnnFfi8YRw5ax+Hf\nonbZOocBAoGBAPGLwJlJ4+prUCv9jTYT3sCX4R/HKbZNsOWRy2DsSdOkaFHcvOLw\nHXprLxpHzXX5BuFF3ue/8ue6ksx04h2B5sW4jt1dVKpBS7AU0YdahOyr2Zmj/V0v\ndnUk5pdVtKrmJs56H90ivnUDMHlrq3ve523/Nv0+gi9toATBlJ2QRwtpAoGBAOi3\nrJuCKVLM7DDAomQ06xzs5e0euCrbK3TenFCisziupctaxI2KE+bV1Ixcr9GXrurs\nh3JMr635IaDS26VksBzmb8Ws/DWWbKdA9a41XtE0jygso+pddUIR5YEE+AtQH47I\nmt+AHk0FAxUzX17Q9jMEpCMpfLSuJF533GNcaVNxAoGBALaAfjQTxTYAgSHLwJ8k\nYkCoQLuO8rBAgTDjeIQx5BIZ/YwkuT7KZ6twQrWbnNzPHGinLyVxPWni6Tm78oCS\n/rdTm/Ybp3XAQhy3jhyzww1DRvU0F6IJ03ntOKENa6VYoeeOFHcz4i1tDHohZP8B\ny2Cr3XN4gEqvjKErVku6kENJAoGBALyY3hHJEqQ/3spD01dSa5gthMj+NFLG/Bji\nr9vJf2VYZJTBIrlyRV61vGNkWjiJrQBGYB6Jd3aOiGpFeCw5xWAmgD67SkpDdhq1\n0mU0a3swFTSBuPWeeADrcAt3c233qRuWB61Jr0TL4wuzbn7w6hW+lSbJ4H6tAlxs\n1vbPVayBAoGAAiABOovuoCmkmWDXrDLpVw+XzLay63rMAmY3Rji7KSuhGAShLuER\nXT34Y8ThYFZHZCinb1G1gw93px+P7AYDhS8ew42pWlGFbTBETOE0gJJfVnMXtBlg\nIjn4IPICzyIkEHqjzF7VLIQ1Ca+vXpuB8GhEc8esrxg5h4Qua09C5yk=\n-----END RSA PRIVATE KEY-----" > hugo-key.pem
  #   - echo "started rncmd commands" >> output_process.txt # Print 
  #   - scp -i hugo-key.pem output_process.txt ubuntu@130.238.28.44:output_process.txt  # Print 
  #   - sudo bash ansible_install.sh
  #   - cd ~
  #   - echo "${openstack_networking_floatingip_v2.floatip_1.address} ansible privade ip" >> output_process.txt # Print 
  #   - scp -i hugo-key.pem output_process.txt ubuntu@130.238.28.44:output_process.txt  # Print 
  #   - sudo -- sh -c "echo ${openstack_networking_floatingip_v2.floatip_1.address} ansible-node >> /etc/hosts"
  #   - echo "${openstack_compute_instance_v2.spark_master.access_ip_v4} spark master privade ip" >> output_process.txt  # Print 
  #   - scp -i hugo-key.pem output_process.txt ubuntu@130.238.28.44:output_process.txt  # Print 
  #   - sudo -- sh -c "echo ${openstack_compute_instance_v2.spark_master.access_ip_v4} ansible-node >> /etc/hosts"
  #   - echo "${openstack_compute_instance_v2.worker.0.access_ip_v4} spark worker privade ip" >> output_process.txt # Print 
  #   - scp -i hugo-key.pem output_process.txt ubuntu@130.238.28.44:output_process.txt  # Print 
  #   - sudo -- sh -c "echo ${openstack_compute_instance_v2.worker.0.access_ip_v4} ansible-node >> /etc/hosts"  # Needs to be done for all worker nodes as well. Tricky.. (step 3)
  #   - ssh-keygen –t rsa -f ansible_key -N ''
  #   - ssh-copy-id -i ansible_key.pub ubuntu@${openstack_compute_instance_v2.spark_master.access_ip_v4} 
  #   - ssh-copy-id -i ansible_key.pub ubuntu@${openstack_compute_instance_v2.worker.0.access_ip_v4} # Needs to be done for all spark worker nodes
  #   - sudo -- sh -c "echo ansible-node ansible_ssh_host=${openstack_networking_floatingip_v2.floatip_1.address} >> /etc/ansible/hosts"
  #   - sudo -- sh -c "echo sparkmaster  ansible_ssh_host=${openstack_compute_instance_v2.spark_master.access_ip_v4} >> /etc/ansible/hosts"
  #   - sudo -- sh -c "echo sparkworker1 ansible_ssh_host=${openstack_compute_instance_v2.worker.0.access_ip_v4} >> /etc/ansible/hosts" # Needs to be done for every worker node.
  #   - sudo -- sh -c "cat /home/ubuntu/add_ansible_hosts >> /etc/ansible/hosts"
  #   - ansible-playbook -b spark_deployment.yaml > output_QTL.txt # Print 
  #   - scp -i hugo-key.pem output_QTL.txt ubuntu@130.238.28.44:output_QTL.txt  # Print 
  # EOF
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