locals {
  control_plane_count    = var.create_control_plane && var.control_plane_count > 0 ? var.control_plane_count : 0
  worker_count           = var.create_worker && var.worker_count > 0 ? var.worker_count : 0
  ext_apiserver_lb_count = var.create_ext_apiserver_lb ? 1 : 0
}

module "control_planes" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.0"

  count = local.control_plane_count

  disks    = local.control_plane_disks
  networks = local.control_plane_networks

  agent            = 1
  automatic_reboot = local.control_plane_settings.automatic_reboot
  balloon          = local.control_plane_settings.balloon
  bios             = local.control_plane_settings.bios
  cicustom         = local.control_plane_settings.cicustom
  cipassword       = local.control_plane_settings.cipassword
  ciuser           = local.control_plane_settings.ciuser
  ci_wait          = local.control_plane_settings.ciwait
  clone            = local.control_plane_template
  cores            = local.control_plane_settings.cores
  cpu              = local.control_plane_settings.cpu
  description      = local.control_plane_settings.description
  full_clone       = true
  hotplug          = local.control_plane_settings.hotplug
  memory           = local.control_plane_settings.memory
  nameserver       = local.control_plane_settings.nameserver
  onboot           = local.control_plane_settings.onboot
  oncreate         = local.control_plane_settings.oncreate
  os_type          = "cloud-init"
  pool             = local.control_plane_settings.pool
  qemu_os          = "l26"
  scsihw           = local.control_plane_settings.scsihw
  searchdomain     = local.control_plane_settings.searchdomain
  sshkeys          = local.control_plane_settings.sshkeys
  sockets          = local.control_plane_settings.sockets
  tablet           = true
  tags             = local.control_plane_settings.tags
  target_node      = local.control_plane_target_node
  vm_name          = local.control_plane_settings.vm_name
  vmid             = local.control_plane_settings.vm_id
}

module "workers" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.0"

  count = local.worker_count

  disks    = local.worker_disks
  networks = local.worker_networks

  agent            = 1
  automatic_reboot = local.worker_settings.automatic_reboot
  balloon          = local.worker_settings.balloon
  bios             = local.worker_settings.bios
  cicustom         = local.worker_settings.cicustom
  cipassword       = local.worker_settings.cipassword
  ciuser           = local.worker_settings.ciuser
  ci_wait          = local.worker_settings.ciwait
  clone            = local.worker_template
  cores            = local.worker_settings.cores
  cpu              = local.worker_settings.cpu
  description      = local.worker_settings.description
  full_clone       = true
  hotplug          = local.worker_settings.hotplug
  memory           = local.worker_settings.memory
  nameserver       = local.worker_settings.nameserver
  onboot           = local.worker_settings.onboot
  oncreate         = local.worker_settings.oncreate
  os_type          = "cloud-init"
  pool             = local.worker_settings.pool
  qemu_os          = "l26"
  scsihw           = local.worker_settings.scsihw
  searchdomain     = local.worker_settings.searchdomain
  sshkeys          = local.worker_settings.sshkeys
  sockets          = local.worker_settings.sockets
  tablet           = true
  tags             = local.worker_settings.tags
  target_node      = local.worker_target_node
  vm_name          = local.worker_settings.vm_name
  vmid             = local.worker_settings.vm_id
}

module "external_lb" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.0"

  count = local.ext_apiserver_lb_count

  disks    = local.ext_apiserver_lb_disks
  networks = local.ext_apiserver_lb_networks

  agent            = 1
  automatic_reboot = local.ext_apiserver_lb_settings.automatic_reboot
  balloon          = local.ext_apiserver_lb_settings.balloon
  bios             = local.ext_apiserver_lb_settings.bios
  cicustom         = local.ext_apiserver_lb_settings.cicustom
  cipassword       = local.ext_apiserver_lb_settings.cipassword
  ciuser           = local.ext_apiserver_lb_settings.ciuser
  ci_wait          = local.ext_apiserver_lb_settings.ciwait
  clone            = local.ext_apiserver_lb_template
  cores            = local.ext_apiserver_lb_settings.cores
  cpu              = local.ext_apiserver_lb_settings.cpu
  description      = local.ext_apiserver_lb_settings.description
  full_clone       = true
  hotplug          = local.ext_apiserver_lb_settings.hotplug
  memory           = local.ext_apiserver_lb_settings.memory
  nameserver       = local.ext_apiserver_lb_settings.nameserver
  onboot           = local.ext_apiserver_lb_settings.onboot
  oncreate         = local.ext_apiserver_lb_settings.oncreate
  os_type          = "cloud-init"
  pool             = local.ext_apiserver_lb_settings.pool
  qemu_os          = "l26"
  scsihw           = local.ext_apiserver_lb_settings.scsihw
  searchdomain     = local.ext_apiserver_lb_settings.searchdomain
  sshkeys          = local.ext_apiserver_lb_settings.sshkeys
  sockets          = local.ext_apiserver_lb_settings.sockets
  tablet           = true
  tags             = local.ext_apiserver_lb_settings.tags
  target_node      = local.ext_apiserver_lb_target_node
  vm_name          = local.ext_apiserver_lb_settings.vm_name
  vmid             = local.ext_apiserver_lb_settings.vm_id
}
