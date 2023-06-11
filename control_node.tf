locals {
  control_node_count = var.create_control_node ? 1 : 0

  vm_name = var.control_node_settings.vm_name
  ciuser  = var.control_node_settings.ciuser
}

resource "local_file" "prepare_control_node_script" {
  content = templatefile("${path.module}/templates/prepare_control_node.sh.tftpl", {
    pods_on_control_node = var.enable_deploy_on_control_node
  })
  filename = "${path.module}/rendered/prepare_control_node.sh"
}

module "control_node" {
  source  = "ZacksHomeLab/cloudinit-vm/proxmox"
  version = "1.6.2"

  # Generate script before proceeding
  depends_on = [local_file.prepare_control_node_script]

  count = local.control_node_count

  vm_name     = local.vm_name
  target_node = var.control_node_settings.target_node
  clone       = var.control_node_settings.vm_template

  agent            = var.control_node_settings.agent
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

data "mod" "name" {
}
# Import shell script into resources
resource "null_resource" "upload_script_to_control_node" {
  depends_on = [module.control_node]
  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = file("~/.ssh/id_ed25519")
    host        = join("", module.control_node[0].proxmox_vm_ip)
  }

  provisioner "file" {
    source      = local_file.prepare_control_node_script.filename
    destination = "/tmp/prepare_control_node.sh"
  }

  triggers = {
    vm_id = join("", module.control_node[0].proxmox_vm_id)
  }
}
# Store the kubeconfig content in an output
output "control_node_vmid" {
  description = "The Control Node's Virtual Machine ID."
  value       = join("", module.control_node[0].proxmox_vm_id)
}
output "control_node_ip" {
  description = "The Control Node's Primary IP Address."
  value       = join("", module.control_node[0].proxmox_vm_ip)
}

