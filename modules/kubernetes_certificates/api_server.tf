/*
  API Server - Server Certificate Private Key: apiserver.key
*/
resource "tls_private_key" "apiserver_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Server Certificate CSR
*/
resource "tls_cert_request" "apiserver_ca_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.apiserver_key[count.index].private_key_pem

  subject {
    common_name = local.apiserver_name
  }

  dns_names = [
    local.control_plane_name,
    local.cluster_name,
    local.cluster_name_and_namespace,
    local.cluster_namespace_fqdn,
    local.cluster_namespace_fqdn_and_domain
  ]

  ip_addresses = [
    local.internal_control_plane_ip,
    local.external_control_plane_ip
  ]

  depends_on = [
    data.tls_public_key.apiserver_key
  ]
}

/*
  API Server - Server Certificate: apiserver.crt
*/
resource "tls_locally_signed_cert" "apiserver_crt" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.apiserver_ca_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.ca_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]

  depends_on = [
    data.tls_certificate.ca_crt,
    data.tls_public_key.ca_key
  ]
}

/*
  API Server - Client Certificate Private Key: apiserver-kubelet-client.key
*/
resource "tls_private_key" "apiserver_client_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Client Certificate CSR
*/
resource "tls_cert_request" "apiserver_client_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.apiserver_kubelet_client_key[count.index].private_key_pem

  subject {
    common_name  = local.apiserver_kubelet_client_cn
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.apiserver_kubelet_client_key
  ]
}


/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
resource "tls_locally_signed_cert" "apiserver_kubelet_client_crt" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.apiserver_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.ca_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.ca_crt,
    data.tls_public_key.ca_key
  ]
}

/*
  API Server - Etcd Client Certificate Private Key: apiserver-etcd-client.key
*/
resource "tls_private_key" "apiserver_etcd_client_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Etcd Client Certificate CSR
*/
resource "tls_cert_request" "apiserver_etcd_client_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.apiserver_etcd_client_key[count.index].private_key_pem

  subject {
    common_name  = local.apiserver_kubelet_client_cn
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.apiserver_etcd_client_key
  ]
}

/*
  API Server - Etcd Client Certificate: apiserver-etcd-client.crt
*/
resource "tls_locally_signed_cert" "apiserver_etcd_client_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.apiserver_etcd_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_crt,
    data.tls_public_key.etcd_ca_key
  ]
}

/*
  API Server - Server Certificate: apiserver.crt
*/
data "tls_certificate" "apiserver_crt" {
  count   = local.create_certificates
  content = tls_locally_signed_cert.apiserver_crt[count.index].cert_pem
}

/*
  API Server - Server Certificate Private Key: apiserver.key
*/
data "tls_public_key" "apiserver_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.apiserver_key[count.index].private_key_pem
}

/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
data "tls_certificate" "apiserver_kubelet_client_crt" {
  count   = local.create_certificates
  content = tls_locally_signed_cert.apiserver_kubelet_client_crt[count.index].cert_pem
}

/*
  API Server - Client Certificate Private Key: apiserver-kubelet-client.key
*/
data "tls_public_key" "apiserver_kubelet_client_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.apiserver_client_key[count.index].private_key_pem
}

/*
  API Server - Etcd Client Certificate: apiserver-etcd-client.crt
*/
data "tls_certificate" "apiserver_etcd_client_crt" {
  count   = local.create_etcd_certificates
  content = tls_locally_signed_cert.apiserver_etcd_client_crt[count.index].cert_pem
}

/*
  API Server - Etcd Client Certificate Private Key: apiserver-etcd-client.key
*/
data "tls_public_key" "apiserver_etcd_client_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.apiserver_etcd_client_key[count.index].private_key_pem
}

output "apiserver_crt" {
  description = "The contents of apiserver.crt."
  value       = trimspace(data.tls_certificate.apiserver_crt[0].content)
}

output "apiserver_key" {
  description = "The contents of apiserver.key and apiserver.pub."
  value       = trimspace(data.tls_public_key.apiserver_key[0].private_key_pem)
  sensitive   = true
}

output "apiserver_kubelet_client_crt" {
  description = "The contents of apiserver-kubelet-client.crt."
  value       = trimspace(data.tls_certificate.apiserver_kubelet_client_crt[0].content)
}

output "apiserver_kubelet_client_key" {
  description = "The contents of apiserver-kubelet-client.key and apiserver-kubelet-client.pub."
  value       = trimspace(data.tls_public_key.apiserver_kubelet_client_key[0].private_key_pem)
  sensitive   = true
}

output "apiserver_etcd_client_crt" {
  description = "The contents of apiserver-etcd-client.crt."
  value       = trimspace(data.tls_certificate.apiserver_etcd_client_crt[0].content)
}

output "apiserver_etcd_client_key" {
  description = "The contents of apiserver-etcd-client.key and apiserver-etcd-client.pub"
  value       = trimspace(data.tls_public_key.apiserver_etcd_client_key[0].private_key_pem)
  sensitive   = true
}
