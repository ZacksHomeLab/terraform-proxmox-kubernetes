/*
  etcd - CA Certificate Private Key: etcd/ca.key
*/
resource "tls_private_key" "etcd_ca_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd - CA Certificate: etcd/ca.crt
*/
resource "tls_self_signed_cert" "etcd_ca_crt" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = true

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]

  dns_names = [
    local.etcd_ca_name
  ]

  subject {
    common_name = local.etcd_ca_name
  }

  depends_on = [
    data.tls_public_key.etcd_ca_key
  ]
}

/*
  etcd Healthcheck Client - Certificate Private Key: etcd/healthcheck-client.key
*/
resource "tls_private_key" "healthcheck_client_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Healthcheck Client - Certificate CSR
*/
resource "tls_cert_request" "healthcheck_client_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.healthcheck_client_key[count.index].private_key_pem

  subject {
    common_name  = local.etcd_healthcheck_name
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.healthcheck_client_key
  ]
}

/*
  etcd Healthcheck Client - Certificate: etcd/healthcheck-client.crt
*/
resource "tls_locally_signed_cert" "healthcheck_client_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.healthcheck_client_csr[count.index].cert_request_pem
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
  etcd Peer - Certificate Private Key: etcd/peer.key
*/
resource "tls_private_key" "etcd_peer_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Peer - Certificate CSR
*/
resource "tls_cert_request" "etcd_peer_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_peer_key[count.index].private_key_pem

  dns_names = [
    "localhost",
    local.control_plane_name,
  ]

  ip_addresses = [
    local.external_control_plane_ip,
    "127.0.0.1",
    "0000:0000:0000:0000:0000:0000:0000:0001"
  ]

  subject {
    common_name = local.control_plane_name
  }

  depends_on = [
    data.tls_public_key.etcd_peer_key
  ]
}

/*
  etcd Peer - Certificate: etcd/peer.crt
*/
resource "tls_locally_signed_cert" "etcd_peer_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_peer_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_crt,
    data.tls_public_key.etcd_ca_key
  ]
}

/*
  etcd Server - Certificate Private Key: etcd/server.key
*/
resource "tls_private_key" "etcd_server_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Server - Certificate CSR
*/
resource "tls_cert_request" "etcd_server_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_server_key[count.index].private_key_pem

  dns_names = [
    "localhost",
    local.control_plane_name,
  ]

  ip_addresses = [
    local.external_control_plane_ip,
    "127.0.0.1",
    "0000:0000:0000:0000:0000:0000:0000:0001"
  ]

  subject {
    common_name = local.control_plane_name
  }

  depends_on = [
    data.tls_public_key.etcd_server_key
  ]
}

/*
  etcd Server - Certificate: etcd/server.crt
*/
resource "tls_locally_signed_cert" "etcd_server_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_server_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_crt,
    data.tls_public_key.etcd_ca_key
  ]
}

/*
  etcd - CA Certificate: etcd/ca.crt
*/
data "tls_certificate" "etcd_ca_crt" {
  count   = local.create_etcd_certificates
  content = tls_self_signed_cert.etcd_ca_crt[count.index].cert_pem
}

output "etcd_ca_crt" {
  description = "The contents of etcd/ca.crt."
  value       = trimspace(data.tls_certificate.etcd_ca_crt[0].content)
  sensitive   = true
}

/*
  etcd - CA Certificate Private Key: etcd/ca.key
*/
data "tls_public_key" "etcd_ca_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_ca_key[count.index].private_key_pem
}

output "etcd_ca_key" {
  description = "The contents of etcd/ca.key."
  value       = trimspace(data.tls_public_key.etcd_ca_key[0].private_key_pem)
  sensitive   = true
}

/*
  etcd Healthcheck Client - Certificate: etcd/healthcheck-client.crt
*/
data "tls_certificate" "healthcheck_client_crt" {
  count   = local.create_etcd_certificates
  content = tls_locally_signed_cert.healthcheck_client_crt[count.index].cert_pem
}

output "healthcheck_client_crt" {
  description = "The contents of etcd/healthcheck-client.crt."
  value       = trimspace(data.tls_certificate.healthcheck_client_crt[0].content)
  sensitive   = true
}

/*
  etcd Healthcheck Client - Certificate Private Key: etcd/healthcheck-client.key
*/
data "tls_public_key" "healthcheck_client_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.healthcheck_client_key[count.index].private_key_pem
}

output "healthcheck_client_key" {
  description = "The contents of etcd/healthcheck-client.key."
  value       = trimspace(data.tls_public_key.healthcheck_client_key[0].private_key_pem)
  sensitive   = true
}

/*
  etcd Peer - Certificate: etcd/peer.crt
*/
data "tls_certificate" "etcd_peer_crt" {
  count   = local.create_etcd_certificates
  content = tls_locally_signed_cert.etcd_peer_crt[count.index].cert_pem
}

output "etcd_peer_crt" {
  description = "The contents of etcd/peer.crt."
  value       = trimspace(data.tls_certificate.etcd_peer_crt[0].content)
  sensitive   = true
}

/*
  etcd Peer - Certificate Private Key: etcd/peer.key
*/
data "tls_public_key" "etcd_peer_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_peer_key[count.index].private_key_pem
}

output "etcd_peer_key" {
  description = "The contents of etcd/peer.key."
  value       = trimspace(data.tls_public_key.etcd_peer_key[0].private_key_pem)
  sensitive   = true
}

/*
  etcd Server - Certificate: etcd/server.crt
*/
data "tls_certificate" "etcd_server_crt" {
  count   = local.create_etcd_certificates
  content = tls_locally_signed_cert.etcd_server_crt[count.index].cert_pem
}

output "etcd_server_crt" {
  description = "The contents of etcd/server.crt."
  value       = trimspace(data.tls_certificate.etcd_server_crt[0].content)
  sensitive   = true
}

/*
  etcd Server - Certificate Private Key: etcd/server.key
*/
data "tls_public_key" "etcd_server_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_server_key[count.index].private_key_pem
}

output "etcd_server_key" {
  description = "The contents of etcd/server.key."
  value       = trimspace(data.tls_public_key.etcd_server_key[0].private_key_pem)
  sensitive   = true
}
