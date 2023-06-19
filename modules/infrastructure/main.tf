module "control_plane" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.6.2"

  count = local.control_node_count

  vm_name     = local.vm_name
  target_node = var.control_node_settings.target_node
  clone       = var.control_node_settings.vm_template

  agent            = 1
  automatic_reboot = var.control_node_settings.automatic_reboot
  bios             = var.control_node_settings.bios
  ciuser           = var.control_node_settings.ciuser
  cipassword       = var.control_node_settings.cipassword
  cicustom         = var.control_node_settings.cicustom
  ci_wait          = var.control_node_settings.ciwait
  cpu              = var.control_node_settings.cpu
  cores            = var.control_node_settings.cores
  description      = var.control_node_settings.description
  full_clone       = true
  memory           = var.control_node_settings.memory
  nameserver       = var.control_node_settings.nameserver
  onboot           = var.control_node_settings.onboot
  oncreate         = var.control_node_settings.oncreate
  os_type          = "cloud-init"
  pool             = var.control_node_settings.pool
  qemu_os          = "l26"
  searchdomain     = var.control_node_settings.searchdomain
  scsihw           = var.control_node_settings.scsihw
  sockets          = var.control_node_settings.sockets
  sshkeys          = var.control_node_settings.sshkeys
  tablet           = true
  tags             = var.control_node_settings.tags
  vmid             = var.control_node_settings.vm_id

  disks    = var.control_node_disks
  networks = var.control_node_networks
}
