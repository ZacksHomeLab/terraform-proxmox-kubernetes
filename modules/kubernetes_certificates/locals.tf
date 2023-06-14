locals {
  create_certificates      = var.create_certificates ? 1 : 0
  create_etcd_certificates = var.create_etcd_certificates ? 1 : 0

  # Name of the control plane
  control_plane_name = var.control_plane_name

  # Internal IP Address of Control Plane (e.g., 10.96.0.1)
  internal_control_plane_ip = var.internal_control_plane_ip
  # External IP Address of Control Plane (e.g., 192.168.2.126)
  external_control_plane_ip = var.external_control_plane_ip

  # Default Value: kubernetes
  cluster_name = var.cluster_name

  # Default Value: cluster.local
  cluster_domain = var.cluster_domain

  # Default Value: default
  cluster_namespace = var.cluster_namespace

  # Default Value: kubernetes.default
  cluster_name_and_namespace = "${local.cluster_name}.${local.cluster_namespace}"
  # Default Value: kubernetes.default.svc
  cluster_namespace_fqdn = "${local.cluster_name_and_namespace}.svc"
  # Default Value: kubernetes.default.svc.cluster.local
  cluster_namespace_fqdn_and_domain = "${local.cluster_namespace_fqdn}.${local.cluster_domain}"

  # Default Value: kube-apiserver
  api_server_name = var.api_server_name

  # Default Value: kube-apiserver-kubelet-client
  api_server_kubelet_client_cn = var.api_server_client_name

  # Default Value: front-proxy-ca
  front_proxy_ca_name = var.front_proxy_name
  # Default Value: front-proxy-client
  front_proxy_client_name = var.front_proxy_client_name

  # Default Value: etcd-ca
  etcd_ca_name = var.etcd_name
  # Default Value: kube-etcd-healthcheck-client
  etcd_healthcheck_name = var.etcd_healthcheck_name

  early_renewal_hours   = var.early_renewal_hours
  validity_period_hours = var.validity_period_hours
  /*
  certificate_files = var.generate_ca_certificates ? [
    {
      filename = "ca.key"
      content  = tls_private_key.kube_ca_priv_key[0].private_key_pem
    },
    {
      filename = "ca.crt"
      content  = tls_self_signed_cert.kube_ca_cert[0].cert_pem
    },
    {
      filename = "apiserver.key"
      content  = tls_private_key.kube_api_server_priv_key[0].private_key_pem
    },
    {
      filename = "apiserver.crt"
      content  = tls_locally_signed_cert.kube_api_server_cert[0].cert_pem
    },
    {
      filename = "apiserver-kubelet-client.key"
      content  = tls_private_key.kube_api_client_private_key[0].private_key_pem
    },
    {
      filename = "apiserver-kubelet-client.crt"
      content  = tls_locally_signed_cert.kube_api_server_client_cert[0].cert_pem
    },
    {
      filename = "sa.key"
      content  = tls_private_key.kube_sa_private_key[0].private_key_pem
    },
    {
      filename = "sa.pub"
      content  = data.tls_public_key.sa_public_key[0].public_key_pem
    },
    {
      filename = "front-proxy-ca.key"
      content  = tls_private_key.kube_front_proxy_ca_priv_key[0].private_key_pem
    },
    {
      filename = "front-proxy-ca.crt"
      content  = tls_self_signed_cert.kube_front_proxy_ca_cert[0].cert_pem
    },
    {
      filename = "front-proxy-client.key"
      content  = tls_private_key.kube_front_proxy_client_priv_key[0].private_key_pem
    },
    {
      filename = "front-proxy-client.crt"
      content  = tls_locally_signed_cert.front_proxy_client_cert[0].cert_pem
    },
  ] : []
  */
}
