# This was not in the guide. Is needed
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}

provider "openstack" {
    auth_url = "https://east-1.cloud.snic.se:8004/v1/c32d121b91b648738e64d50490c05505" # Auth_ur was need. Taken from https://east-1.cloud.snic.se/project/api_access/
}