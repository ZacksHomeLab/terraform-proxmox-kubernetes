locals {

}

module "infrastructure" {
  source = "./modules/infrastructure"

  disks    = var.disks
  settings = var.settings
  networks = var.networks

  target_node = var.target_node
  template    = var.template

  control_plane = {
    count = local.control_plane_count

    automatic_reboot = try(var.control_plane_settings.automatic_reboot, var.settings.automatic_reboot)
    balloon          = try(var.control_plane_settings.balloon, var.settings.balloon)
    bios             = try(var.control_plane_settings.bios, var.settings.bios)
    cicustom         = try(var.control_plane_settings.cicustom, var.settings.cicustom)
    cipassword       = try(var.control_plane_settings.cipassword, var.settings.cipassword)
    ciuser           = try(var.control_plane_settings.ciuser, var.settings.ciuser)
    ciwait           = try(var.control_plane_settings.ciwait, var.settings.ciwait)
    cores            = try(var.control_plane_settings.cores, var.settings.cores)
    cpu              = try(var.control_plane_settings.cpu, var.settings.cpu)
    description      = try(var.control_plane_settings.description, var.settings.description)
    hotplug          = try(var.control_plane_settings.hotplug, var.settings.hotplug)
    memory           = try(var.control_plane_settings.memory, var.settings.memory)
    nameserver       = try(var.control_plane_settings.nameserver, var.settings.nameserver)
    onboot           = try(var.control_plane_settings.onboot, var.settings.onboot)
    oncreate         = try(var.control_plane_settings.oncreate, var.settings.oncreate)
    pool             = try(var.control_plane_settings.pool, var.settings.pool)
    scsihw           = try(var.control_plane_settings.scsihw, var.settings.scsihw)
    searchdomain     = try(var.control_plane_settings.searchdomain, var.settings.searchdomain)
    sshkeys          = try(var.control_plane_settings.sshkeys, var.settings.sshkeys)
    sockets          = try(var.control_plane_settings.sockets, var.settings.sockets)
    tags             = try(var.control_plane_settings.tags, var.settings.tags)
    vm_id            = try(var.control_plane_settings.vm_id, var.settings.vm_id)


    control_plane_disks    = var.control_plane_disks
    control_plane_networks = var.control_plane_networks
    control_plane_settings = var.control_plane_settings

    #control_plane_vm_name = "ZHLPLANE"
    #control_plane_target_node = ""
    #control_plane_template = ""

    #control_plane_cidr = ""
    #control_plane_gateway = ""

    #control_plane_settings = var.control_plane_settings
    #control_plane_disks = var.control_plane_disks
    #control_plane_networks = var.control_plane_networks
  }
}
