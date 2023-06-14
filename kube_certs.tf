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

  primary_cert_files = var.create_certificates ? [
    {
      filename = "ca.key"
      #content  = module.certs.data.tls_certificate.etcd_server_cert.content
    }
  ] : []
  /*
  certificate_files = var.generate_ca_certificates ? [
    {
      filename = "ca.key"
      content  = tls_private_key.kube_ca_priv_key.private_key_pem
    },
    {
      filename = "ca.crt"
      content  = tls_self_signed_cert.kube_ca_cert.cert_pem
    },
    {
      filename = "apiserver.key"
      content  = tls_private_key.kube_api_server_priv_key.private_key_pem
    },
    {
      filename = "apiserver.crt"
      content  = tls_locally_signed_cert.kube_api_server_cert.cert_pem
    },
    {
      filename = "apiserver-kubelet-client.key"
      content  = tls_private_key.kube_api_client_private_key.private_key_pem
    },
    {
      filename = "apiserver-kubelet-client.crt"
      content  = tls_locally_signed_cert.kube_api_server_client_cert.cert_pem
    },
    {
      filename = "sa.key"
      content  = tls_private_key.kube_sa_private_key.private_key_pem
    },
    {
      filename = "sa.pub"
      content  = data.tls_public_key.sa_public_key.public_key_pem
    },
    {
      filename = "front-proxy-ca.key"
      content  = tls_private_key.kube_front_proxy_ca_priv_key.private_key_pem
    },
    {
      filename = "front-proxy-ca.crt"
      content  = tls_self_signed_cert.kube_front_proxy_ca_cert.cert_pem
    },
    {
      filename = "front-proxy-client.key"
      content  = tls_private_key.kube_front_proxy_client_priv_key.private_key_pem
    },
    {
      filename = "front-proxy-client.crt"
      content  = tls_locally_signed_cert.front_proxy_client_cert.cert_pem
    },
  ] : []*/
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
