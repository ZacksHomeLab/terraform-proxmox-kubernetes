locals {
  import_certs                 = (var.create_certificates || var.create_etcd_certificates) && local.control_plane_count > 0 ? local.control_plane_count : 0
  cert_destinations            = local.import_certs > 0 ? join(" ", module.certs.all_certificates_destinations) : ""
  prepare_node_script_template = "${path.module}/templates/prepare_control_node.sh.tftpl"
  prepare_node_script_rendered = "${path.module}/rendered/prepare_control_node.sh"
  prepare_node_script_dest     = "/tmp/${basename(local.prepare_node_script_rendered)}"

  # Generate the 'join' token for Kubernetes
  kube_token = "${random_string.prefix.result}.${random_string.suffix.result}"

  ciuser      = var.control_plane_settings.ciuser
  private_key = file(var.private_key)
}

resource "local_file" "prepare_control_node_script" {

  content = templatefile(local.prepare_node_script_template, {
    pods_on_control_node = var.pods_on_control_plane
    cluster_domain       = var.cluster_domain
    cluster_name         = var.cluster_name
    cluster_namespace    = var.cluster_namespace
    pod_network          = var.pod_network
    service_network      = var.service_network
    kube_token           = local.kube_token
    import_ssl           = var.create_certificates
    cert_destinations    = local.cert_destinations
  })
  filename = local.prepare_node_script_rendered
}

# Import shell script into resources
resource "null_resource" "setup_control_node" {
  count      = local.control_plane_count
  depends_on = [module.control_planes, local_file.prepare_control_node_script, module.certs]

  connection {
    type        = "ssh"
    user        = local.ciuser
    private_key = local.private_key
    host        = module.control_planes[count.index].ip
  }

  provisioner "file" {
    source      = local_file.prepare_control_node_script.filename
    destination = local.prepare_node_script_dest
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ${local.prepare_node_script_dest}",
      (var.create_certificates ? "sudo ${local.prepare_node_script_dest} ${jsonencode(module.certs.all_certificates)}" : "sudo ${local.prepare_node_script_dest}")
      #"sudo rm ${local.prepare_node_script_dest}"
    ]
  }

  triggers = {
    vmid = module.control_planes[count.index].vmid
  }
}
