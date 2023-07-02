module "control_planes" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.1"

  count = local.control_plane_count

  disks    = local.control_plane_disks_with_settings[count.index]
  networks = local.control_plane_nics_with_settings[count.index]

  agent            = 1
  automatic_reboot = local.control_plane_settings[count.index].automatic_reboot
  balloon          = local.control_plane_settings[count.index].balloon
  bios             = local.control_plane_settings[count.index].bios
  cicustom         = local.control_plane_settings[count.index].cicustom
  cipassword       = local.control_plane_settings[count.index].cipassword
  ciuser           = local.control_plane_settings[count.index].ciuser
  ci_wait          = local.control_plane_settings[count.index].ciwait
  clone            = local.control_plane_template[count.index]
  cores            = local.control_plane_settings[count.index].cores
  cpu              = local.control_plane_settings[count.index].cpu
  description      = local.control_plane_settings[count.index].description
  full_clone       = true
  hotplug          = local.control_plane_settings[count.index].hotplug
  memory           = local.control_plane_settings[count.index].memory
  nameserver       = local.control_plane_settings[count.index].nameserver
  onboot           = local.control_plane_settings[count.index].onboot
  oncreate         = local.control_plane_settings[count.index].oncreate
  os_type          = "cloud-init"
  pool             = local.control_plane_settings[count.index].pool
  qemu_os          = "l26"
  scsihw           = local.control_plane_settings[count.index].scsihw
  searchdomain     = local.control_plane_settings[count.index].searchdomain
  sshkeys          = local.control_plane_settings[count.index].sshkeys
  sockets          = local.control_plane_settings[count.index].sockets
  tablet           = true
  tags             = local.control_plane_settings[count.index].tags != null ? local.control_plane_settings[count.index].tags : []
  target_node      = local.control_plane_target_node[count.index]
  vm_name          = local.control_plane_vm_name[count.index]
  vmid             = local.control_plane_settings[count.index].vm_id
}

module "workers" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.1"

  count = local.worker_count

  disks    = local.worker_disks_with_settings[count.index]
  networks = local.worker_nics_with_settings[count.index]

  agent            = 1
  automatic_reboot = local.worker_settings[count.index].automatic_reboot
  balloon          = local.worker_settings[count.index].balloon
  bios             = local.worker_settings[count.index].bios
  cicustom         = local.worker_settings[count.index].cicustom
  cipassword       = local.worker_settings[count.index].cipassword
  ciuser           = local.worker_settings[count.index].ciuser
  ci_wait          = local.worker_settings[count.index].ciwait
  clone            = local.worker_template[count.index]
  cores            = local.worker_settings[count.index].cores
  cpu              = local.worker_settings[count.index].cpu
  description      = local.worker_settings[count.index].description
  full_clone       = true
  hotplug          = local.worker_settings[count.index].hotplug
  memory           = local.worker_settings[count.index].memory
  nameserver       = local.worker_settings[count.index].nameserver
  onboot           = local.worker_settings[count.index].onboot
  oncreate         = local.worker_settings[count.index].oncreate
  os_type          = "cloud-init"
  pool             = local.worker_settings[count.index].pool
  qemu_os          = "l26"
  scsihw           = local.worker_settings[count.index].scsihw
  searchdomain     = local.worker_settings[count.index].searchdomain
  sshkeys          = local.worker_settings[count.index].sshkeys
  sockets          = local.worker_settings[count.index].sockets
  tablet           = true
  tags             = local.worker_settings[count.index].tags != null ? local.worker_settings[count.index].tags : []
  target_node      = local.worker_target_node[count.index]
  vm_name          = local.worker_vm_name[count.index]
  vmid             = local.worker_settings[count.index].vm_id
}

module "ext_apiserver_lb" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.7.1"

  count = local.ext_apiserver_lb_count

  disks    = local.ext_apiserver_lb_disks_with_settings[count.index]
  networks = local.ext_apiserver_lb_nics_with_settings[count.index]

  agent            = 1
  automatic_reboot = local.ext_apiserver_lb_settings[count.index].automatic_reboot
  balloon          = local.ext_apiserver_lb_settings[count.index].balloon
  bios             = local.ext_apiserver_lb_settings[count.index].bios
  cicustom         = local.ext_apiserver_lb_settings[count.index].cicustom
  cipassword       = local.ext_apiserver_lb_settings[count.index].cipassword
  ciuser           = local.ext_apiserver_lb_settings[count.index].ciuser
  ci_wait          = local.ext_apiserver_lb_settings[count.index].ciwait
  clone            = local.ext_apiserver_lb_template[count.index]
  cores            = local.ext_apiserver_lb_settings[count.index].cores
  cpu              = local.ext_apiserver_lb_settings[count.index].cpu
  description      = local.ext_apiserver_lb_settings[count.index].description
  full_clone       = true
  hotplug          = local.ext_apiserver_lb_settings[count.index].hotplug
  memory           = local.ext_apiserver_lb_settings[count.index].memory
  nameserver       = local.ext_apiserver_lb_settings[count.index].nameserver
  onboot           = local.ext_apiserver_lb_settings[count.index].onboot
  oncreate         = local.ext_apiserver_lb_settings[count.index].oncreate
  os_type          = "cloud-init"
  pool             = local.ext_apiserver_lb_settings[count.index].pool
  qemu_os          = "l26"
  scsihw           = local.ext_apiserver_lb_settings[count.index].scsihw
  searchdomain     = local.ext_apiserver_lb_settings[count.index].searchdomain
  sshkeys          = local.ext_apiserver_lb_settings[count.index].sshkeys
  sockets          = local.ext_apiserver_lb_settings[count.index].sockets
  tablet           = true
  #tags             = length(local.ext_apiserver_lb_settings[count.index].tags) > 0 ? [for tag in local.ext_apiserver_lb_settings[count.index].tags : tag] : []
  #tags             = local.ext_apiserver_lb_settings[count.index].tags != null ? local.ext_apiserver_lb_settings[count.index].tags : []
  target_node = local.ext_apiserver_lb_target_node[count.index]
  vm_name     = local.ext_apiserver_lb_vm_name[count.index]
  vmid        = local.ext_apiserver_lb_settings[count.index].vm_id

}
