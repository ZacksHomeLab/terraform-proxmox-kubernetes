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
}

/*
  etcd Healthcheck Client - Certificate Private Key: etcd/healthcheck-client.key
*/
resource "tls_private_key" "etcd_healthcheck_client_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Healthcheck Client - Certificate CSR
*/
resource "tls_cert_request" "etcd_healthcheck_client_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_healthcheck_client_key[count.index].private_key_pem

  subject {
    common_name  = local.etcd_healthcheck_name
    organization = "system:masters"
  }
}

/*
  etcd Healthcheck Client - Certificate: etcd/healthcheck-client.crt
*/
resource "tls_locally_signed_cert" "etcd_healthcheck_client_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_healthcheck_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].certificates[count.index].cert_pem
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
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
    for name in concat(local.control_plane_names, tolist(["localhost"])) : tostring(name)
  ]

  ip_addresses = [
    for ip in concat(local.external_control_plane_ips, tolist(["127.0.0.1", "0000:0000:0000:0000:0000:0000:0000:0001"])) : tostring(ip)
  ]

  subject {
    common_name = local.control_plane_names[0]
  }
}

/*
  etcd Peer - Certificate: etcd/peer.crt
*/
resource "tls_locally_signed_cert" "etcd_peer_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_peer_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].certificates[count.index].cert_pem
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
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
    for name in concat(local.control_plane_names, tolist(["localhost"])) : tostring(name)
  ]

  ip_addresses = [
    for ip in concat(local.external_control_plane_ips, tolist(["127.0.0.1", "0000:0000:0000:0000:0000:0000:0000:0001"])) : tostring(ip)
  ]

  subject {
    common_name = local.control_plane_names[0]
  }
}

/*
  etcd Server - Certificate: etcd/server.crt
*/
resource "tls_locally_signed_cert" "etcd_server_crt" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_server_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_crt[count.index].certificates[count.index].cert_pem
  ca_private_key_pem = data.tls_public_key.etcd_ca_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
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
  value       = var.create_etcd_certificates ? data.tls_certificate.etcd_ca_crt[0].certificates[0].cert_pem : null
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
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_ca_key[0].private_key_pem : null
  sensitive   = true
}

/*
  etcd - CA Certificate Public Key: etcd/ca.pub
*/
output "etcd_ca_pub" {
  description = "The contents of etcd/ca.pub."
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_ca_key[0].public_key_pem : null
  sensitive   = true
}

/*
  etcd Healthcheck Client - Certificate: etcd/healthcheck-client.crt
*/
data "tls_certificate" "etcd_healthcheck_client_crt" {
  count   = local.create_etcd_certificates
  content = tls_locally_signed_cert.etcd_healthcheck_client_crt[count.index].cert_pem
}

output "etcd_healthcheck_client_crt" {
  description = "The contents of etcd/healthcheck-client.crt."
  value       = var.create_etcd_certificates ? data.tls_certificate.etcd_healthcheck_client_crt[0].certificates[0].cert_pem : null
  sensitive   = true
}

/*
  etcd Healthcheck Client - Certificate Private Key: etcd/healthcheck-client.key
*/
data "tls_public_key" "etcd_healthcheck_client_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_healthcheck_client_key[count.index].private_key_pem
}

output "etcd_healthcheck_client_key" {
  description = "The contents of etcd/healthcheck-client.key."
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_healthcheck_client_key[0].private_key_pem : null
  sensitive   = true
}

/*
  etcd Healthcheck Client - Certificate Public Key: etcd/healthcheck-client.pub
*/
output "etcd_healthcheck_client_pub" {
  description = "The contents of etcd/healthcheck-client.pub."
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_healthcheck_client_key[0].public_key_pem : null
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
  value       = var.create_etcd_certificates ? data.tls_certificate.etcd_peer_crt[0].certificates[0].cert_pem : null
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
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_peer_key[0].private_key_pem : null
  sensitive   = true
}

/*
  etcd Peer - Certificate Public Key: etcd/peer.pub
*/
output "etcd_peer_pub" {
  description = "The contents of etcd/peer.pub."
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_peer_key[0].public_key_pem : null
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
  value       = var.create_etcd_certificates ? data.tls_certificate.etcd_server_crt[0].certificates[0].cert_pem : null
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
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_server_key[0].private_key_pem : null
  sensitive   = true
}

/*
  etcd Server - Certificate Public Key: etcd/server.pub
*/
output "etcd_server_pub" {
  description = "The contents of etcd/server.pub."
  value       = var.create_etcd_certificates ? data.tls_public_key.etcd_server_key[0].public_key_pem : null
  sensitive   = true
}
