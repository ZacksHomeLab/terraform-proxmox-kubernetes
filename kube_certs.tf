/*
  DO NOT MODIFY ANYTHING IN LOCALS!!!
*/
locals {
  create_certificates = var.generate_ca_certificates ? 1 : 0

  # Name of the control plane
  control_plane_vm_name = var.control_node_settings.vm_name

  # Internal IP Address of Control Plane (e.g., 10.96.0.1)
  internal_control_plane_ip = "10.96.0.1"
  # External IP Address of Control Plane (e.g., 192.168.2.126)
  external_control_plane_ip = "192.168.2.126"

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
  api_server_name = var.cluster_api_server_name

  # Default Value: kube-apiserver-kubelet-client
  api_server_kubelet_client_cn = "${local.api_server_name}-kubelet-client"

  # Default Value: front-proxy-ca
  front_proxy_ca_name = "front-proxy-ca"
  # Default Value: front-proxy-client
  front_proxy_client_name = "front-proxy-client"

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
  ] : []
}

/*
  Private Key: ca.key
*/
resource "tls_private_key" "kube_ca_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  CA Certificate: ca.crt
*/
resource "tls_self_signed_cert" "kube_ca_cert" {
  private_key_pem       = tls_private_key.kube_ca_priv_key.private_key_pem
  is_ca_certificate     = true
  early_renewal_hours   = 740
  validity_period_hours = 87600

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]

  subject {
    common_name = local.cluster_name
  }

  dns_names = [
    local.cluster_name
  ]
}


/*
  API Server - Server Certificate Private Key: apiserver.key
*/
resource "tls_private_key" "kube_api_server_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Server Certificate CSR
    We will use this to generate a server certificate that meets the requirements:
    - Be a serving server certificate (x509.ExtKeyUsageServerAuth).
	  - Contains altnames for:
		  - The Kubernetes service's internal clusterIP (e.g. 10.96.0.1).
		  - Kubernetes DNS names (e.g. kubernetes.default.svc.zackshomelab.com).
		  - The node-name (e.g., ZHLControlPlane01).
		  - The --apiserver-advertise-address (e.g., 192.168.2.126).
      - (optional) other alt names
*/
resource "tls_cert_request" "kube_api_server_csr" {
  private_key_pem = tls_private_key.kube_api_server_priv_key.private_key_pem
  subject {
    common_name = local.api_server_name
  }

  dns_names = [
    local.control_plane_vm_name,
    local.cluster_name,
    local.cluster_name_and_namespace,
    local.cluster_namespace_fqdn,
    local.cluster_namespace_fqdn_and_domain
  ]
  ip_addresses = [
    local.internal_control_plane_ip,
    local.external_control_plane_ip
  ]
}

/*
  API Server - Server Certificate: apiserver.crt
*/
resource "tls_locally_signed_cert" "kube_api_server_cert" {
  cert_request_pem   = tls_cert_request.kube_api_server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.kube_ca_priv_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube_ca_cert.cert_pem

  is_ca_certificate = false

  early_renewal_hours   = 740
  validity_period_hours = 87600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

/*
  API Server - Client Certificate Private Key: apiserver-kubelet-client.key
*/
resource "tls_private_key" "kube_api_client_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Client Certificate CSR
*/
resource "tls_cert_request" "kube_api_server_client_csr" {
  private_key_pem = tls_private_key.kube_api_client_private_key.private_key_pem

  subject {
    common_name  = local.api_server_kubelet_client_cn
    organization = "system:masters"
  }
}

/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
resource "tls_locally_signed_cert" "kube_api_server_client_cert" {
  cert_request_pem   = tls_cert_request.kube_api_server_client_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.kube_ca_priv_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube_ca_cert.cert_pem

  is_ca_certificate = false

  early_renewal_hours   = 740
  validity_period_hours = 87600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]
}

/*
  Service Account - Private Key: sa.key
*/
resource "tls_private_key" "kube_sa_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Service Account - Public Key: sa.pub
*/
data "tls_public_key" "sa_public_key" {
  private_key_pem = tls_private_key.kube_sa_private_key.private_key_pem
}

/*
  Front Proxy - Private Key: front-proxy-ca.key
*/
resource "tls_private_key" "kube_front_proxy_ca_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - CA Certificate: front-proxy-ca.crt
*/
resource "tls_self_signed_cert" "kube_front_proxy_ca_cert" {
  private_key_pem   = tls_private_key.kube_front_proxy_ca_priv_key.private_key_pem
  is_ca_certificate = true

  early_renewal_hours   = 740
  validity_period_hours = 87600

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment"
  ]

  subject {
    common_name = local.front_proxy_ca_name
  }

  dns_names = [
    local.front_proxy_ca_name
  ]
}

/*
  Front Proxy - Client Private Key: front-proxy-client.key
*/
resource "tls_private_key" "kube_front_proxy_client_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - Client Certificate CSR
*/
resource "tls_cert_request" "kube_front_proxy_client_csr" {
  private_key_pem = tls_private_key.kube_front_proxy_client_priv_key.private_key_pem

  subject {
    common_name = local.front_proxy_client_name
  }
}

/*
  Front Proxy - Client Certificate: front-proxy-client.crt
*/
resource "tls_locally_signed_cert" "front_proxy_client_cert" {
  cert_request_pem   = tls_cert_request.kube_front_proxy_client_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.kube_front_proxy_ca_priv_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube_front_proxy_ca_cert.cert_pem

  is_ca_certificate = false

  early_renewal_hours   = 740
  validity_period_hours = 87600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]
}
