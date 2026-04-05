terraform {
  required_providers {
    null = { source = "hashicorp/null" }
  }
}

resource "null_resource" "devops_server" {
  provisioner "local-exec" {
    command = "echo 'Simulating EC2 instance creation on Mac'"
  }
}