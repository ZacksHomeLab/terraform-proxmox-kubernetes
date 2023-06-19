/*
  DO NOT MODIFY ANYTHING IN LOCALS!!!
*/
locals {
  # Name of the control plane
  control_plane_vm_name = var.control_node_settings.vm_name

  # Internal IP Address of Control Plane (e.g., 10.96.0.1)
  internal_control_plane_ip = "10.96.0.1"
  # External IP Address of Control Plane (e.g., 192.168.2.126)
  external_control_plane_ip = "192.168.2.126"
}

module "certs" {
  source = "./modules/kubernetes_certificates"

  create_certificates      = var.create_certificates
  create_etcd_certificates = var.create_etcd_certificates

  cluster_name      = var.cluster_name
  cluster_domain    = var.cluster_domain
  cluster_namespace = var.cluster_domain

  control_plane_name        = local.control_plane_vm_name
  internal_control_plane_ip = local.internal_control_plane_ip
  external_control_plane_ip = local.external_control_plane_ip
}
