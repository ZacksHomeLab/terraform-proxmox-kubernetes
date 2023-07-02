/*
  This file computers all of the necessary local variables for k8_infrastructure.tf.
*/
locals {

  inventory = yamldecode(file("${path.module}/inventory.yml"))

  # Load Virtual Machine data from inventory.yml
  control_plane_vms    = can(local.inventory["control_planes"]) ? local.inventory["control_planes"] : null
  worker_vms           = can(local.inventory["workers"]) ? local.inventory["workers"] : null
  ext_apiserver_lb_vms = can(local.inventory["ext_apiserver_lb"]) ? local.inventory["ext_apiserver_lb"] : null

  # Determine the amount of Virtual Machine to create
  control_plane_count    = var.create_control_plane && can(length(local.control_plane_vms) > 0) ? length(local.control_plane_vms) : 0
  worker_count           = var.create_worker && can(length(local.worker_vms) > 0) ? length(local.worker_vms) : 0
  ext_apiserver_lb_count = var.create_ext_apiserver_lb && can(length(local.ext_apiserver_lb_vms) > 0) && !var.create_apiserver_lb ? length(local.ext_apiserver_lb_vms) : 0

  # Load the default values from inventory.yml
  defaults         = try(local.inventory["defaults"])
  default_disks    = { for i, disk in values(local.defaults.disks) : i => disk }
  default_nics     = { for i, nic in values(local.defaults.nics) : i => nic }
  default_settings = local.defaults.settings

  # Determine what address to use for the API Server Load Balancer
  apiserver_lb_virtual_ip = var.apiserver_lb_virtual_ip

  # These are all the disk settings that can be set on a Virtual Machine
  disk_settings = [
    "storage",
    "size",
    "type",
    "format",
    "cache",
    "backup",
    "iothread",
    "discard",
    "replicate",
    "ssd",
    "mbps",
    "mbps_rd",
    "mbps_rd_max",
    "mbps_wr",
    "mbps_wr_max",
    "iops",
    "iops_rd",
    "iops_rd_max",
    "iops_rd_max_length",
    "iops_wr",
    "iops_wr_max",
    "iops_wr_max_length"
  ]

  # These are all the network adapter settings that can be set on a Virtual Machine
  nic_settings = [
    "ip",
    "ip6",
    "gateway",
    "gateway6",
    "dhcp",
    "dhcp6",
    "bridge",
    "model",
    "firewall",
    "link_down",
    "macaddr",
    "queues",
    "rate",
    "vlan_tag"
  ]

  # These are all the Virtual Machine settings that can be set on a Virtual Machine
  vm_settings = [
    "automatic_reboot",
    "balloon",
    "bios",
    "cicustom",
    "cipassword",
    "ciuser",
    "ciwait",
    "cores",
    "cpu",
    "description",
    "hotplug",
    "memory",
    "nameserver",
    "onboot",
    "oncreate",
    "pool",
    "scsihw",
    "searchdomain",
    "sshkeys",
    "sockets",
    "tags",
    "vm_id"
  ]


  /*
    Retrieve Proxmox Target Node, OS Template, and Virtual Machine names for Control Plane Virtual Machines.

    If the Target Node and OS Template do NOT exist, retrieve these values from the Default(s) section in the inventory file.
  */
  control_plane_target_node = local.control_plane_count > 0 ? [for vm in local.control_plane_vms : can(vm.target_node) ? vm.target_node : local.defaults.target_node] : []
  control_plane_template    = local.control_plane_count > 0 ? [for vm in local.control_plane_vms : can(vm.template) ? vm.template : local.defaults.template] : []
  control_plane_vm_name     = local.control_plane_count > 0 ? [for vm in local.control_plane_vms : vm.name if can(vm.name)] : []


  /*
    This variable will iterate through all of the provided Control Plane Virtual Machines and
      check if the current Virtual Machine has provided 'disks'. If the Virtual Machine has
      provided disks, we will add those disks to the current variable.

    If the user has provided 'extra' default disks. For example, if the user has provided 2 disks
      as the default for all Virtual Machines, but the Control Plane VM has 1 disk, we need to
      retrieve the second disk and add it onto the Control Plane VM.

    If the user has Control Plane disks and the amoount of default disks is less than or equal to
      the amount of Control Plane disks (e.g., 1 Control Plane disk(s) and 1 default diisk(s)),
      we will use the Control Plane disks. Otherwise, we will use the Default Disks.
  */
  control_plane_disks = local.control_plane_count > 0 ? {
    for i, vm in values(local.control_plane_vms) : i => can(vm.disks) ? flatten([
      [
        for i, disk in vm.disks : disk
      ],
      length(local.default_disks) > length(vm.disks) ?
      [
        for j, disk in range(0, length(local.default_disks) - length(vm.disks)) : local.default_disks[length(vm.disks) + j]
      ] : []
    ]) : [for i, disk in local.default_disks : disk]
  } : {}

  /*
    This variable holds our Control Plane Virtual Machine disks and their respected disk 'settings'.

    As the variable 'control_plane_disks' figures out which disks each Virtual Machine should have,
      we need to iterate through each Virtual Machine and add the 'settings' to each disk.

    First, we iterate through each Virtual Machine, within each Virtual Machine, we will
      begin iterating through each of their disks.

    During each disk iteration, we will go through each possible disk 'setting' in
      local.disk_setting.

    If the current disk has the current setting, apply the setting. Otherwise, look for the default
      disk setting of the current disk number. For example, if we are iterating through
      the second disk of a Virtual Machine, look for the default disk setting of the second disk
      (if it exists).

    Otherwise, look for the default disk setting of the first disk (if it exists).
  */
  control_plane_disks_with_settings = local.control_plane_count > 0 ? {
    for i, vm in values(local.control_plane_disks) : i => flatten([
      for j, disk in vm : {
        for setting in local.disk_settings :
        setting => try(disk[setting], try(local.default_disks[j][setting], try(local.default_disks[0][setting], null)))
      }
    ])
  } : {}

  /*
    This variable holds Control Plane Virtual Machines and their respected Network Adapters (i.e., 'nics').

    This will iterate through all of the provided Control Plane Virtual Machines and
      check if the current Virtual Machine has provided 'nics'. If the Virtual Machine has
      provided nics, we will add those nics to the current variable. Otherwise, we will use the
      default nics.

    If the user has provided 'extra' default nics. For example, if the user has provided 2 nics
      as the default for all Virtual Machines, but the Control Plane VM has 1 nic, we need to
      retrieve the second nic and add it onto the Control Plane VM.
  */
  control_plane_nics = local.control_plane_count > 0 ? {
    for i, vm in values(local.control_plane_vms) : i => can(vm.nics) ? flatten([
      [
        for i, nic in vm.nics : nic
      ],
      length(local.default_nics) > length(vm.nics) ?
      [
        for j, nic in range(0, length(local.default_nics) - length(vm.nics)) : local.default_nics[length(vm.nics) + j]
      ] : []
    ]) : [for i, nic in local.default_nics : nic]
  } : {}


  /*
    This variable holds our Control Plane Virtual Machine nics with 'settings'.

    As the variable 'control_plane_nics' figures out which nics each Virtual Machine should have,
      we need to iterate through each Virtual Machine and add the 'settings' to each nic.

    First, we iterate through each Virtual Machine, within each Virtual Machine, we will
      begin iterating through each of their nics.

    During each nic iteration, we will go through each possible nic 'setting' in
      local.nic_setting.

    If the current nic has the current setting, apply the setting. Otherwise, look for the default
      nic setting of the current nic number. For example, if we are iterating through
      the second nic of a Virtual Machine, look for the default nic setting of the second nic
      (if it exists).

    Otherwise, look for the default nic setting of the first nic (if it exists).
  */
  control_plane_nics_with_settings = local.control_plane_count > 0 ? {
    for i, vm in values(local.control_plane_nics) : i => flatten([
      for j, nic in vm : {
        for setting in local.nic_settings :
        setting => try(nic[setting], try(local.default_nics[j][setting], try(local.default_nics[0][setting], null)))
      }
    ])
  } : {}

  /*
    This variable holds our Control Plane Virtual Machine settings.

    First, we iterate through each Virtual Machine,

    During each setting iteration, we will go through each possible setting in
      local.vm_setting.

    If the current Virtual Machine has the current setting, apply the setting. Otherwise, look for the default
      Virtual Machine setting (if it exists).
  */
  control_plane_settings = local.control_plane_count > 0 ? {
    for i, vm in values(local.control_plane_vms) : i => {
      for setting in local.vm_settings :
      setting => try(vm.settings[setting], try(local.default_settings[setting], null))
    }
  } : {}


  worker_target_node = local.worker_count > 0 ? [for vm in local.worker_vms : can(vm.target_node) ? vm.target_node : local.defaults.target_node] : null
  worker_template    = local.worker_count > 0 ? [for vm in local.worker_vms : can(vm.template) ? vm.template : local.defaults.template] : null
  worker_vm_name     = local.worker_count > 0 ? [for vm in local.worker_vms : vm.name if can(vm.name)] : null

  worker_disks = local.worker_count > 0 ? {
    for i, vm in values(local.worker_vms) : i => can(vm.disks) ? flatten([
      [
        for i, disk in vm.disks : disk
      ],
      length(local.default_disks) > length(vm.disks) ?
      [
        for j, disk in range(0, length(local.default_disks) - length(vm.disks)) : local.default_disks[length(vm.disks) + j]
      ] : []
    ]) : [for i, disk in local.default_disks : disk]
  } : {}

  worker_disks_with_settings = local.worker_count > 0 ? {
    for i, vm in values(local.worker_disks) : i => flatten([
      for j, disk in vm : {
        for setting in local.disk_settings :
        setting => try(disk[setting], try(local.default_disks[j][setting], try(local.default_disks[0][setting], null)))
      }
    ])
  } : {}

  worker_nics = local.worker_count > 0 ? {
    for i, vm in values(local.worker_vms) : i => can(vm.nics) ? flatten([
      [
        for i, nic in vm.nics : nic
      ],
      length(local.default_nics) > length(vm.nics) ?
      [
        for j, nic in range(0, length(local.default_nics) - length(vm.nics)) : local.default_nics[length(vm.nics) + j]
      ] : []
    ]) : [for i, nic in local.default_nics : nic]
  } : {}

  worker_nics_with_settings = local.worker_count > 0 ? {
    for i, vm in values(local.worker_nics) : i => flatten([
      for j, nic in vm : {
        for setting in local.nic_settings :
        setting => try(nic[setting], try(local.default_nics[j][setting], try(local.default_nics[0][setting], null)))
      }
    ])
  } : {}

  worker_settings = local.worker_count > 0 ? {
    for i, vm in values(local.worker_vms) : i => {
      for setting in local.vm_settings :
      setting => try(vm.settings[setting], try(local.default_settings[setting], null))
    }
  } : {}



  ext_apiserver_lb_target_node = local.ext_apiserver_lb_count > 0 ? [for vm in local.ext_apiserver_lb_vms : can(vm.target_node) ? vm.target_node : local.defaults.target_node] : null
  ext_apiserver_lb_template    = local.ext_apiserver_lb_count > 0 ? [for vm in local.ext_apiserver_lb_vms : can(vm.template) ? vm.template : local.defaults.template] : null
  ext_apiserver_lb_vm_name     = local.ext_apiserver_lb_count > 0 ? [for vm in local.ext_apiserver_lb_vms : vm.name if can(vm.name)] : null

  ext_apiserver_lb_disks = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in values(local.ext_apiserver_lb_vms) : i => can(vm.disks) ? flatten([
      [
        for i, disk in vm.disks : disk
      ],
      length(local.default_disks) > length(vm.disks) ?
      [
        for j, disk in range(0, length(local.default_disks) - length(vm.disks)) : local.default_disks[length(vm.disks) + j]
      ] : []
    ]) : [for i, disk in local.default_disks : disk]
  } : {}

  ext_apiserver_lb_disks_with_settings = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in values(local.ext_apiserver_lb_disks) : i => flatten([
      for j, disk in vm : {
        for setting in local.disk_settings :
        setting => try(disk[setting], try(local.default_disks[j][setting], try(local.default_disks[0][setting], null)))
      }
    ])
  } : {}

  ext_apiserver_lb_nics = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in values(local.ext_apiserver_lb_vms) : i => can(vm.nics) ? flatten([
      [
        for i, nic in vm.nics : nic
      ],
      length(local.default_nics) > length(vm.nics) ?
      [
        for j, nic in range(0, length(local.default_nics) - length(vm.nics)) : local.default_nics[length(vm.nics) + j]
      ] : []
    ]) : [for i, nic in local.default_nics : nic]
  } : {}

  ext_apiserver_lb_nics_with_settings = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in values(local.ext_apiserver_lb_nics) : i => flatten([
      for j, nic in vm : {
        for setting in local.nic_settings :
        setting => try(nic[setting], try(local.default_nics[j][setting], try(local.default_nics[0][setting], null)))
      }
    ])
  } : {}

  ext_apiserver_lb_settings = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in values(local.ext_apiserver_lb_vms) : i => {
      for setting in local.vm_settings :
      setting => try(vm.settings[setting], try(local.default_settings[setting], null))
    }
  } : {}
}
