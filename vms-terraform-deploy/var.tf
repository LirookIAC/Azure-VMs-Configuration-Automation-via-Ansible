variable "vms" {
  type = map(object({
    name  = string
    offer = string
    sku   = string
    publisher = string
    version = string
    plan_required = bool
  }))
  default = {
    "Ubuntu-vm" = {
      name  = "ubuntu-vm"
      offer = "ubuntu-24_04-lts"
      sku   = "server"
      publisher = "Canonical"
      version = "latest"
      plan_required = false # This VM does not require a plan
    },
    rhel-vm = {
      name  = "rhel-vm"
      publisher = "procomputers"
      offer     = "rocky-linux-9-lvm"
      sku       = "rocky-linux-9-lvm" # Or "8-base" for Rocky 8
      version   = "latest"
      plan_required = true # This VM requires a plan
    },
    "suse-vm" = {
      name  = "suse-vm"
      publisher = "suse"
      offer     = "sles-15-sp5-basic"
      sku       = "gen2"
      version   = "latest"
      plan_required = false # This VM does not require a plan
    }
  }
}