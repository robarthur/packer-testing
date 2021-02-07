locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "vmware-iso" "test" {
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
  http_directory         = "./http"
  iso_checksum           = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
  iso_target_path        = "iso/"
  iso_urls               = ["iso/ubuntu-20.04.2-live-server-amd64.iso", "https://releases.ubuntu.com/focal/ubuntu-20.04.2-live-server-amd64.iso"]
  memory                 = "4096"
  cores                  = "4"
  output_directory       = "output/live-server"
  shutdown_command       = "sudo shutdown -P now"
  tools_upload_flavor    = "linux"
  ssh_handshake_attempts = 20
  ssh_password           = "ubuntu"
  ssh_pty                = true
  ssh_timeout            = "30m"
  ssh_username           = "ubuntu"
}

# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    "source.vmware-iso.test"
  ]

  provisioner "shell" {
    inline = ["ls /"]
  }
}