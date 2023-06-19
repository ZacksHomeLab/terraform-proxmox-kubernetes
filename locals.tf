locals {
  control_plane_count = var.create_control_plane && var.control_plane_count > 0 ? var.control_plane_count : 0
  worker_count        = var.create_worker && var.worker_count > 0 ? var.worker_count : 0

  /*
    If the user decides to add more than one disk as the default for all Virtual Machines.
      There needs to be a variable to track the 'additional' drives that should be added
      to each Virtual Machine.
  */
  extra_disk_count = local.control_plane_count > 0 && (length(var.disks) > length(var.control_plane_disks)) ? length(var.disks) - length(var.control_plane_disks) : 0
  extra_disks      = local.extra_disk_count > 0 ? [for i in range(0, local.extra_disk_count) : var.disks[length(var.control_plane_disks) + i]] : []

  /*
    This contraption will iterate through all of the provided Control Plane Disks and
      check the value of each element to see if it's null or not. if the value is null,
      we will look at the default disk for its value (if it exists) and use that value for the
      empty key=value.

    Additionally, I wanted a single variable to perform the action rather than creating
      multiple local variables that do type conversions, merging, compacting, etc.

    An example, two provided control plane disks may look like this:
      control_plane_disks = [
        {
          storage = "control-plane-storage"
        },
        {
          storage = "local-pve2"
        }
      ]

    This variable will convert the above to:
      # Retrieve default values from provided default_disk
      disks = [{
        backup = true
        size = "10G"
      }]

      # Control Plane disks have default values added to each disk.
      control_plane_disks = [
        {
          backup = true
          size = "10G"
          storage = "control-plane-storage"
        },
        {
          backup = true
          size = "10G"
          storage = "local-pve2"
        }
      ]
  */
  control_plane_disks = length(var.control_plane_disks) > 0 ? flatten([
    [for i, disk in var.control_plane_disks : {
      for key, value in disk :
      key => (value != null ? value : try(lookup(var.disks[i], "${key}", null), try(lookup(var.disks[0], "${key}", null), null)))
    }], [local.extra_disks]
  ]) : var.disks

  /*
    See comments above extra_disk_count
  */
  extra_disk_count_worker = local.worker_count > 0 && (length(var.disks) > length(var.worker_disks)) ? length(var.disks) - length(var.worker_disks) : 0
  extra_disks_worker      = local.extra_disk_count_worker > 0 ? [for i in range(0, local.extra_disk_count_worker) : var.disks[length(var.worker_disks) + i]] : []

  /*
    See comments above control_plane_disks
  */
  worker_disks = length(var.worker_disks) > 0 ? flatten([
    [for i, disk in var.worker_disks : {
      for key, value in disk :
      key => (value != null ? value : try(lookup(var.disks[i], "${key}", null), try(lookup(var.disks[0], "${key}", null), null)))
    }], [local.extra_disks_worker]
  ]) : var.disks


  /*
    See comments above extra_disk_count
  */
  extra_nic_count = local.control_plane_count > 0 && (length(var.networks) > length(var.control_plane_networks)) ? length(var.networks) - length(var.control_plane_networks) : 0
  extra_nics      = local.extra_nic_count > 0 ? [for i in range(0, local.extra_nic_count) : var.networks[length(var.control_plane_networks) + i]] : []

  /*
    See comments above control_plane_disks

    This utilizes the same processes as control_plane_disks.
  */
  control_plane_networks = length(var.control_plane_networks) > 0 ? flatten([
    [for i, nic in var.control_plane_networks : {
      for key, value in nic :
      key => (value != null ? value : try(lookup(var.networks[i], "${key}", null), try(lookup(var.networks[0], "${key}", null), null)))
    }], [local.extra_nics]
  ]) : var.networks

  /*
    See comments above extra_disk_count
  */
  extra_nic_count_worker = local.worker_count > 0 && (length(var.networks) > length(var.worker_networks)) ? length(var.networks) - length(var.worker_networks) : 0
  extra_nics_worker      = local.extra_nic_count_worker > 0 ? [for i in range(0, local.extra_nic_count_worker) : var.networks[length(var.worker_networks) + i]] : []

  /*
    See comments above worker_networks

    This utilizes the same processes as control_plane_disks.
  */
  worker_networks = length(var.worker_networks) > 0 ? flatten([
    [for i, nic in var.worker_networks : {
      for key, value in nic :
      key => (value != null ? value : try(lookup(var.networks[i], "${key}", null), try(lookup(var.networks[0], "${key}", null), null)))
    }], [local.extra_nics_worker]
  ]) : var.networks

  /*
    Disclaimer: using merge and compact would get ths job done for what this is trying to do.

    This will iterate through the provided control_plane_settings and if said key=value is null,
      it will look for the default value in var.settings. If that's not found, give a null value.
  */
  control_plane_settings = local.control_plane_count > 0 ? { for key, value in var.control_plane_settings :
    key => (value != null ? value : try(lookup(var.settings, "${key}", null), null))
  } : null

  /*
    Read comment above control_plane_settings
  */
  worker_settings = local.worker_count > 0 ? { for key, value in var.worker_settings :
    key => (value != null ? value : try(lookup(var.settings, "${key}", null), null))
  } : null
}
