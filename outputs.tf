output "control_planes_ip" {
  description = "The primary IP addresses of each Control Plane Virtual Machine."
  value = local.control_plane_count > 0 ? {
    for i, vm in module.control_planes : tostring(i) => {
      ip = vm.ip
    }
  } : null
}

output "control_planes_vm_name" {
  description = "The Virtual Machine Name of each Control Plane."
  value = local.control_plane_count > 0 ? {
    for i, vm in module.control_planes : tostring(i) => {
      vm_name = vm.name
    }
  } : null
}

output "control_planes_ssh" {
  description = "The ssh settings of each Control Plane Virtual Machine."
  value = local.control_plane_count > 0 ? {
    for i, vm in module.control_planes : tostring(i) => {
      vm_name  = vm.name
      ssh_host = vm.ssh_settings.ssh_host
      ssh_port = vm.ssh_settings.ssh_port
      ssh_user = vm.ssh_settings.ssh_user
      sshkeys  = vm.ssh_settings.sshkeys
    }
  } : null
  sensitive = true
}

output "ext_apiserver_lb_vm_name" {
  description = "The Virtual Machine Name of each External API Server."
  value = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in module.ext_apiserver_lb : tostring(i) => {
      vm_name = vm.name
    }
  } : null
}

output "ext_apiserver_lb_ip" {
  description = "The primary IP addresses of each External API Server Virtual Machine."
  value = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in module.ext_apiserver_lb : tostring(i) => {
      ip = vm.ip
    }
  } : null
}

output "ext_apiserver_lb_ssh" {
  description = "The ssh settings of each External API Server Virtual Machine."
  value = local.ext_apiserver_lb_count > 0 ? {
    for i, vm in module.ext_apiserver_lb : tostring(i) => {
      vm_name  = vm.name
      ssh_host = vm.ssh_settings.ssh_host
      ssh_port = vm.ssh_settings.ssh_port
      ssh_user = vm.ssh_settings.ssh_user
      sshkeys  = vm.ssh_settings.sshkeys
    }
  } : null
  sensitive = true
}
