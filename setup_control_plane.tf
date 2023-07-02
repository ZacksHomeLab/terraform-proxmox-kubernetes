locals {

  import_certs = (var.create_certificates || var.create_etcd_certificates) && local.control_plane_count > 0 ? local.control_plane_count : 0

  prepare_node_script_template = "${path.module}/templates/prepare_control_node.sh.tftpl"
  prepare_node_script_rendered = "${path.module}/rendered/prepare_control_node.sh"
  prepare_node_script_dest     = "/tmp/${basename(local.prepare_node_script_rendered)}"

  init_kubeadm_script_template = "${path.module}/templates/init_kubeadm.sh.tftpl"
  init_kubeadm_script_rendered = "${path.module}/rendered/init_kubeadm.sh"
  init_kubeadm_script_dest     = "/tmp/${basename(local.init_kubeadm_script_rendered)}"

  # Generate the 'join' token for Kubernetes
  kube_token  = "${random_string.prefix.result}.${random_string.suffix.result}"
  private_key = file(var.private_key)
}

resource "local_file" "prepare_control_node_script" {
  count = local.control_plane_count > 0 ? 1 : 0

  content = templatefile(local.prepare_node_script_template, {
    cert_destinations   = local.import_certs > 0 ? join(" ", module.certs[0].all_certificates_destinations) : ""
    create_apiserver_lb = var.create_apiserver_lb
    import_ssl          = var.create_certificates
  })
  filename = local.prepare_node_script_rendered
}

resource "local_file" "init_kubeadm_script" {
  count = local.control_plane_count > 0 ? 1 : 0

  content = templatefile(local.init_kubeadm_script_template, {
    apiserver_dest_port  = var.apiserver_dest_port
    cluster_domain       = var.cluster_domain
    cluster_namespace    = var.cluster_namespace
    create_apiserver_lb  = var.create_apiserver_lb || var.create_ext_apiserver_lb ? true : false
    etcd_dest_port       = var.etcd_dest_port
    etcd_src_port        = var.etcd_src_port
    lb_port              = var.apiserver_lb_port
    import_ssl           = var.create_certificates
    kube_token           = local.kube_token
    pod_network          = var.pod_network
    pods_on_control_node = var.pods_on_control_plane
    service_network      = var.service_network
    virtual_ip           = local.apiserver_lb_virtual_ip
  })
  filename = local.init_kubeadm_script_rendered
}

resource "null_resource" "prepare_control_planes" {
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
        ${var.create_certificates ? "sudo '${local.prepare_node_script_dest}' ${jsonencode(module.certs[0].all_certificates)}" : "sudo '${local.prepare_node_script_dest}'"} && \
        sudo rm '${local.prepare_node_script_dest}'
      EOT
      ,
    ]
  }

  # Prevent this resource from running until control_planes(s) are fully provisioned
  depends_on = [module.control_planes]
}

/*
  Initialize the first control plane node.
*/
resource "null_resource" "init_kubeadm" {
  count = local.control_plane_count > 0 ? 1 : 0

  connection {
    host        = module.control_planes[0].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.control_planes[0].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.init_kubeadm_script[0].filename
    destination = local.init_kubeadm_script_dest
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x '${local.init_kubeadm_script_dest}' && \
        sudo '${local.init_kubeadm_script_dest}' INIT && \
        sudo rm '${local.init_kubeadm_script_dest}'
      EOT
      ,
    ]
  }

  triggers = {
    vmid = module.control_planes[0].vmid
  }

  /*
    If we are using an external load balancer, we need to wait for it to be ready.

    Otherwise, kubeadm init / kubeadmin join will fail.
  */
  depends_on = [null_resource.prepare_control_planes, null_resource.setup_ext_apiserver_lb, null_resource.setup_primary_apiserver_lb]
}

/*
  Initialize any additional Control Plane(s).
*/
resource "null_resource" "join_kubeadm" {
  count = local.control_plane_count > 1 ? local.control_plane_count - 1 : 0

  connection {
    host        = module.control_planes[count.index + 1].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.control_planes[count.index + 1].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.init_kubeadm_script[0].filename
    destination = local.init_kubeadm_script_dest
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x '${local.init_kubeadm_script_dest}' && \
        sudo '${local.init_kubeadm_script_dest}' JOIN && \
        sudo rm '${local.init_kubeadm_script_dest}'
      EOT
      ,
    ]
  }

  triggers = {
    vmid = module.control_planes[count.index + 1].vmid
  }

  /*
    Wait until the first Control Plane is created so
       we don't get any errors upon joining the cluster.
  */
  depends_on = [null_resource.init_kubeadm]
}
