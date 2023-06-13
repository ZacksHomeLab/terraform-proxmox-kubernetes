locals {
  create_certificates = var.generate_ca_certificates ? 1 : 0

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
  validity_period_hours = 87600
  allowed_uses          = ["cert_signing", "crl_signing"]
  subject {
    common_name = "MyKubernetesCA"
  }
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
  dns_names = [
    "DNS:kubernetes.default.svc.zackshomelab.com",
    "DNS:ZHLControlPlane01",
  ]
  ip_addresses = [
    "IP:10.96.0.1",
    "IP:192.168.2.126",
  ]
}

/*
  API Server - Server Certificate: apiserver.crt
*/
resource "tls_locally_signed_cert" "kube_api_server_cert" {
  cert_request_pem      = tls_cert_request.kube_api_server_csr.cert_request_pem
  ca_private_key_pem    = tls_private_key.kube_ca_priv_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.kube_ca_cert.cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature", "key_encipherment", "server_auth"]
  is_ca_certificate     = false
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
    organization = "system:masters"
  }
}

/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
resource "tls_locally_signed_cert" "kube_api_server_client_cert" {
  cert_request_pem      = tls_cert_request.kube_api_server_client_csr.cert_request_pem
  ca_private_key_pem    = tls_private_key.kube_ca_priv_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.kube_ca_cert.cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature", "key_encipherment", "client_auth"]
  is_ca_certificate     = false
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
  private_key_pem       = tls_private_key.kube_front_proxy_ca_priv_key.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 87600
  allowed_uses          = ["cert_signing", "crl_signing"]
  subject {
    common_name = "FrontProxyCA"
  }

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
}

/*
  Front Proxy - Client Certificate: front-proxy-client.crt
*/
resource "tls_locally_signed_cert" "front_proxy_client_cert" {
  cert_request_pem      = tls_cert_request.kube_front_proxy_client_csr.cert_request_pem
  ca_private_key_pem    = tls_private_key.kube_front_proxy_client_priv_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.kube_front_proxy_ca_cert.cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature", "key_encipherment", "client_auth"]
  is_ca_certificate     = false
}
