
locals {
  timestamp         = regex_replace(timestamp(), "[- TZ:]", "")
  private_deploykey = vault("/secret/data/deploykey", "private")
}

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

  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh/",
      "chmod 700 ~/.ssh/",
      "echo \"${local.private_deploykey}\" > /home/ubuntu/.ssh/id_rsa",
      "chmod 600 ~/.ssh/id_rsa"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get install -y git",
      "ssh-keyscan github.com >> ~/.ssh/known_hosts",
      "git clone git@github.com:robarthur/packer-testing.git"
    ]
  }
}