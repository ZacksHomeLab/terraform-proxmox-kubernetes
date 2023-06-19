locals {
  control_node_count = var.create_control_node ? 1 : 0

  upload_certs               = (var.create_certificates || var.create_etcd_certificates) && local.control_node_count > 0 ? 1 : 0
  upload_certs_script_source = "${path.module}/rendered/import_ssl_files.sh"
  upload_certs_script_dest   = "/tmp/${basename(local.upload_certs_script_source)}"

  prepare_node_script_template = "${path.module}/templates/prepare_control_node.sh.tftpl"
  prepare_node_script_rendered = "${path.module}/rendered/prepare_control_node.sh"
  prepare_node_script_dest     = "/tmp/${basename(local.prepare_node_script_rendered)}"

  # Generate the 'join' token for Kubernetes
  kube_token = "${random_string.prefix.result}.${random_string.suffix.result}"

  vm_name     = var.control_node_settings.vm_name
  ciuser      = var.control_node_settings.ciuser
  private_key = file(var.private_key)
}

resource "local_file" "prepare_control_node_script" {
  content = templatefile("${local.prepare_node_script_template}", {
    pods_on_control_node = var.enable_deploy_on_control_node
    cluster_domain       = var.cluster_domain
    cluster_name         = var.cluster_name
    cluster_namespace    = var.cluster_namespace
    pod_network          = var.pod_network
    service_network      = var.service_network
    kube_token           = local.kube_token
  })
  filename = local.prepare_node_script_rendered
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

# Import shell script into resources
resource "null_resource" "setup_control_node" {
  count      = local.control_node_count
  depends_on = [module.control_node]

  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = local.private_key
    host        = join("", module.control_node[count.index].proxmox_vm_ip)
  }

  provisioner "file" {
    source      = local_file.prepare_control_node_script.filename
    destination = local.prepare_node_script_dest
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ${local.prepare_node_script_dest}",
      "sudo ${local.prepare_node_script_dest}",
      "sudo rm ${local.prepare_node_script_dest}"
    ]
  }

  triggers = {
    vm_id = join("", module.control_node[count.index].proxmox_vm_id)
  }
}

/*
  Upload kubernetes SSL certificates to their respected location(s) on the control node.
*/
resource "null_resource" "upload_certs" {
  count = local.upload_certs

  depends_on = [null_resource.setup_control_node, module.certs]

  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = local.private_key
    host        = join("", module.control_node[count.index].proxmox_vm_ip)
  }

  provisioner "file" {
    source      = local.upload_certs_script_source
    destination = local.upload_certs_script_dest
  }

  /*
    Using a for_each would have created 20+ resources, and each for_each would
      create a new SSH connection to said node. To upload all of the certificates
      in one connection, I came up with this one-liner.

    Doing this also allows me to use 'count' with this resource. You can't use count
      and for_each within the same resource.
  */
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ${local.upload_certs_script_dest}",
      "sudo ${local.upload_certs_script_dest} '${jsonencode(module.certs.all_certificates)}'",
      "sudo rm ${local.upload_certs_script_dest}"
    ]
  }
  triggers = {
    vm_id = join("", module.control_node[count.index].proxmox_vm_id)
  }
}
