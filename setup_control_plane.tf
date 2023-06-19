locals {
  upload_certs               = (var.create_certificates || var.create_etcd_certificates) && local.control_plane_count > 0 ? 1 : 0
  upload_certs_script_source = "${path.module}/rendered/import_ssl_files.sh"
  upload_certs_script_dest   = "/tmp/${basename(local.upload_certs_script_source)}"

  prepare_node_script_template = "${path.module}/templates/prepare_control_node.sh.tftpl"
  prepare_node_script_rendered = "${path.module}/rendered/prepare_control_node.sh"
  prepare_node_script_dest     = "/tmp/${basename(local.prepare_node_script_rendered)}"

  # Generate the 'join' token for Kubernetes
  kube_token = "${random_string.prefix.result}.${random_string.suffix.result}"

  vm_name     = var.control_plane_settings.vm_name
  ciuser      = var.control_plane_settings.ciuser
  private_key = file(var.private_key)
}

resource "local_file" "prepare_control_node_script" {
  content = templatefile("${local.prepare_node_script_template}", {
    pods_on_control_node = var.pods_on_control_plane
    cluster_domain       = var.cluster_domain
    cluster_name         = var.cluster_name
    cluster_namespace    = var.cluster_namespace
    pod_network          = var.pod_network
    service_network      = var.service_network
    kube_token           = local.kube_token
  })
  filename = local.prepare_node_script_rendered
}

# Import shell script into resources
resource "null_resource" "setup_control_node" {
  count      = 0
  depends_on = [module.control_planes]

  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = local.private_key
    host        = join("", module.control_planes[count.index].proxmox_vm_ip)
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
    #vm_id = join("", module.infrastructure[count.index].proxmox_vm_id)
  }
}

/*
  Upload kubernetes SSL certificates to their respected location(s) on the control node.
*/
resource "null_resource" "upload_certs" {
  count = 0

  depends_on = [null_resource.setup_control_node, module.certs]

  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = local.private_key
    host        = join("", module.control_planes[count.index].proxmox_vm_ip)
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
    #vm_id = join("", module.infrastructure[count.index].proxmox_vm_id)
  }
}
