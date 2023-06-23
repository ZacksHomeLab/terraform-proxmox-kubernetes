output "control_planes_ip" {
  description = "The primary IP addresses of each Virtual Machine."
  value = local.control_plane_count > 0 ? {
    for vm in module.control_planes : vm.name => {
      ip = vm.ip
    }
  } : null
}

output "control_planes_ssh" {
  description = "The ssh settings of each Virtual Machine."
  value = local.control_plane_count > 0 ? {
    for vm in module.control_planes : vm.name => {
      ssh_host = vm.ssh_settings.ssh_host
      ssh_port = vm.ssh_settings.ssh_port
      ssh_user = vm.ssh_settings.ssh_user
      sshkeys  = vm.ssh_settings.sshkeys
    }
  } : null
  sensitive = true
}
