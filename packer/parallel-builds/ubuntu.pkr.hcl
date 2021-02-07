locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "vmware-iso" "test-ubuntu-server" {
      # Enter the menu to run a custom boot command
      # Delete the existing values <bs>*83
      # Run the install using cloud init.
      # Files are served to cloudinit from a local http server
      boot_command= [
        " <wait><enter><wait>",
        "<f6><esc>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs>",
        "/casper/vmlinuz ",
        "initrd=/casper/initrd ",
        "autoinstall ",
        "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
        "<enter>"
      ]
  boot_wait              = "5s"
  guest_os_type          = "ubuntu-64"
  http_directory         = "./http/server"
  iso_checksum           = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
  iso_target_path        = "iso/"
  # Try to use a local iso first, otherwise pull from the web.
  iso_urls               = ["iso/ubuntu-20.04.2-live-server-amd64.iso", "https://releases.ubuntu.com/focal/ubuntu-20.04.2-live-server-amd64.iso"]
  memory                 = "4096"
  cores                  = "4"
  output_directory       = "output/ubuntu-"
  shutdown_command       = "sudo shutdown -P now"
  tools_upload_flavor    = "linux"
  ssh_handshake_attempts = 20
  ssh_password           = "ubuntu"
  ssh_pty                = true
  ssh_timeout            = "30m"
  ssh_username           = "ubuntu"
}

source "vmware-iso" "test-ubuntu-desktop" {
      # Enter the menu to run a custom boot command
      # Delete the existing values <bs>*83
      # Run the install using cloud init.
      # Files are served to cloudinit from a local http server
      boot_command= [
        " <wait><enter><wait>",
        "<f6><esc>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "<bs><bs><bs>",
        "/casper/vmlinuz ",
        "initrd=/casper/initrd ",
        "autoinstall ",
        "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
        "<enter>"
      ]
  boot_wait              = "5s"
  guest_os_type          = "ubuntu-64"
  http_directory         = "./http/desktop/"
  iso_checksum           = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
  iso_target_path        = "iso/"
  # Try to use a local iso first, otherwise pull from the web.
  # We can't use the autoinstall with ubuntu desktop, so install the server
  # image and then install ubuntu-desktop package.
  iso_urls               = ["iso/ubuntu-20.04.2-live-server-amd64.iso", "https://releases.ubuntu.com/focal/ubuntu-20.04.2-live-server-amd64.iso"]
  memory                 = "4096"
  cores                  = "4"
  output_directory       = "output/ubuntu-desktop/"
  shutdown_command       = "sudo shutdown -P now"
  tools_upload_flavor    = "linux"
  ssh_handshake_attempts = 20
  ssh_password           = "ubuntu"
  ssh_pty                = true
  ssh_timeout            = "30m"
  ssh_username           = "ubuntu"
}


source "amazon-ebs" "test-us-east-1" {
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

source "amazon-ebs" "test-us-east-2" {
  ami_name      = "packer test ${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-2"
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
    "source.vmware-iso.test-ubuntu-server",
    "source.vmware-iso.test-ubuntu-desktop",
    "source.amazon-ebs.test-us-east-1",
    "source.amazon-ebs.test-us-east-2"
  ]

  provisioner "file" {
    source = "motd"
    destination = "/tmp/motd"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/motd /etc/motd"]
  }
}