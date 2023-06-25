locals {

  import_certs = (var.create_certificates || var.create_etcd_certificates) && local.control_plane_count > 0 ? local.control_plane_count : 0

  prepare_node_script_template = "${path.module}/templates/prepare_control_node.sh.tftpl"
  prepare_node_script_rendered = "${path.module}/rendered/prepare_control_node.sh"
  prepare_node_script_dest     = "/tmp/${basename(local.prepare_node_script_rendered)}"

  # Generate the 'join' token for Kubernetes
  kube_token  = "${random_string.prefix.result}.${random_string.suffix.result}"
  private_key = file(var.private_key)
}

resource "local_file" "prepare_control_node_script" {
  count = local.control_plane_count > 0 ? 1 : 0

  content = templatefile(local.prepare_node_script_template, {
    cert_destinations    = local.import_certs > 0 ? join(" ", module.certs[count.index].all_certificates_destinations) : ""
    cluster_domain       = var.cluster_domain
    cluster_name         = var.cluster_name
    cluster_namespace    = var.cluster_namespace
    import_ssl           = var.create_certificates
    kube_token           = local.kube_token
    pod_network          = var.pod_network
    pods_on_control_node = var.pods_on_control_plane
    service_network      = var.service_network
  })
  filename = local.prepare_node_script_rendered
}

# Import shell script into resources
resource "null_resource" "setup_control_node" {
  count = local.control_plane_count

  connection {
    host        = module.control_planes[count.index].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.control_planes[count.index].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.prepare_control_node_script[0].filename
    destination = local.prepare_node_script_dest
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x '${local.prepare_node_script_dest}' && \
        ${var.create_certificates ? "sudo '${local.prepare_node_script_dest}' ${jsonencode(module.certs.all_certificates)}" : "sudo '${local.prepare_node_script_dest}'"} && \
        sudo rm '${local.prepare_node_script_dest}'
      EOT
      ,
    ]
  }

  triggers = {
    vmid = module.control_planes[count.index].vmid
  }

  # Prevent this resource from running until control_planes(s) are fully provisioned
  depends_on = [module.control_planes]
}
