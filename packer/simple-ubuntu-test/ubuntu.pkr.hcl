
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "test" {
  ami_name      = "packer test ${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    "source.amazon-ebs.test"
  ]

  provisioner "file" {
    source = "motd"
    destination = "/tmp/motd"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/motd /etc/motd"]
  }
}