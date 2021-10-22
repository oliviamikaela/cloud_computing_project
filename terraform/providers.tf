# This was not in the guide. Is needed
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}

# info here: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs#auth_url
provider "openstack" {
    #auth_url = "https://east-1.cloud.snic.se:5000/v3"
    #user_name = "s15543" # Auth_ur was need. Taken from https://east-1.cloud.snic.se/project/api_access/
    #password = "A1234567r"
    #region = "east-1"
}