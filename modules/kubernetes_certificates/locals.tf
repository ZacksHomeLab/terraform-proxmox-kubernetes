locals {
  create_certificates      = var.create_certificates ? 1 : 0
  create_etcd_certificates = var.create_etcd_certificates ? 1 : 0

  cert_directory      = trimsuffix(var.certificate_directory, "/")
  etcd_cert_directory = trimsuffix(var.etcd_certificate_directory, "/")

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
  apiserver_name = var.apiserver_name

  # Default Value: kube-apiserver-kubelet-client
  apiserver_kubelet_client_cn = var.apiserver_client_name

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

  primary_files = var.create_certificates ? flatten([
    {
      filename = "${local.cert_directory}/ca.crt"
      content  = trimspace(data.tls_certificate.ca_crt[0].content)
    },
    {
      filename = "${local.cert_directory}/ca.key"
      content  = trimspace(data.tls_public_key.ca_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/apiserver.crt"
      content  = trimspace(data.tls_certificate.apiserver_crt[0].content)
    },
    {
      filename = "${local.cert_directory}/apiserver.key"
      content  = trimspace(data.tls_public_key.apiserver_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/apiserver-kubelet-client.crt"
      content  = trimspace(data.tls_certificate.apiserver_kubelet_client_crt[0].content)
    },
    {
      filename = "${local.cert_directory}/apiserver-kubelet-client.key"
      content  = trimspace(data.tls_public_key.apiserver_kubelet_client_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/front-proxy.crt"
      content  = trimspace(data.tls_certificate.front_proxy_crt[0].content)
    },
    {
      filename = "${local.cert_directory}/front-proxy.key"
      content  = trimspace(data.tls_public_key.front_proxy_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/front-proxy-client.crt"
      content  = trimspace(data.tls_certificate.front_proxy_client_crt[0].content)
    },
    {
      filename = "${local.cert_directory}/front-proxy-client.key"
      content  = trimspace(data.tls_public_key.front_proxy_client_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/sa.key"
      content  = trimspace(data.tls_public_key.sa_key[0].private_key_pem)
    },
    {
      filename = "${local.cert_directory}/sa.pub"
      content  = trimspace(data.tls_public_key.sa_key[0].public_key_pem)
    }
  ]) : []

  etcd_files = var.create_etcd_certificates ? flatten([
    {
      filename = "${local.etcd_cert_directory}/apiserver-etcd-client.crt"
      content  = trimspace(data.tls_certificate.apiserver_etcd_client_crt[0].content)
    },
    {
      filename = "${local.etcd_cert_directory}/apiserver-etcd-client.key"
      content  = trimspace(data.tls_public_key.apiserver_etcd_client_key[0].private_key_pem)
    },
    {
      filename = "${local.etcd_cert_directory}/ca.crt"
      content  = trimspace(data.tls_certificate.etcd_ca_crt[0].content)
    },
    {
      filename = "${local.etcd_cert_directory}/ca.key"
      content  = trimspace(data.tls_public_key.etcd_ca_key[0].private_key_pem)
    },
    {
      filename = "${local.etcd_cert_directory}/healthcheck-client.crt"
      content  = trimspace(data.tls_certificate.etcd_healthcheck_client_crt[0].content)
    },
    {
      filename = "${local.etcd_cert_directory}/healthcheck-client.key"
      content  = trimspace(data.tls_public_key.etcd_healthcheck_client_key[0].private_key_pem)
    },
    {
      filename = "${local.etcd_cert_directory}/peer.crt"
      content  = trimspace(data.tls_certificate.etcd_peer_crt[0].content)
    },
    {
      filename = "${local.etcd_cert_directory}/peer.key"
      content  = trimspace(data.tls_public_key.etcd_peer_key[0].private_key_pem)
    },
    {
      filename = "${local.etcd_cert_directory}/server.crt"
      content  = trimspace(data.tls_certificate.etcd_server_crt[0].content)
    },
    {
      filename = "${local.etcd_cert_directory}/server.key"
      content  = trimspace(data.tls_public_key.etcd_server_key[0].private_key_pem)
    }
  ]) : []

  # Combine both lists into a single list
  all_files = flatten(concat(
    local.primary_files,
    local.etcd_files
  ))

  primary_cert_files = { for i, cert in local.primary_files : tostring(i) => cert }
  etcd_cert_files    = { for i, cert in local.etcd_files : tostring(i) => cert }

  # Convert all_files into a map, which can be used for for-each resources.
  all_cert_files = { for i, cert in local.all_files : tostring(i) => cert }
}
