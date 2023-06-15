/*
  Front Proxy - Private Key: front-proxy-ca.key
*/
resource "tls_private_key" "front_proxy_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - CA Certificate: front-proxy-ca.crt
*/
resource "tls_self_signed_cert" "front_proxy_crt" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.front_proxy_key[count.index].private_key_pem

  is_ca_certificate = true

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment"
  ]

  dns_names = [
    local.front_proxy_ca_name
  ]

  subject {
    common_name = local.front_proxy_ca_name
  }

  depends_on = [
    data.tls_public_key.front_proxy_key
  ]
}

/*
  Front Proxy - Client Private Key: front-proxy-client.key
*/
resource "tls_private_key" "front_proxy_client_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - Client Certificate CSR
*/
resource "tls_cert_request" "front_proxy_client_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.front_proxy_client_key[count.index].private_key_pem

  subject {
    common_name = local.front_proxy_client_name
  }

  depends_on = [
    data.tls_public_key.front_proxy_client_key
  ]
}

/*
  Front Proxy - Client Certificate: front-proxy-client.crt
*/
resource "tls_locally_signed_cert" "front_proxy_client_crt" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.front_proxy_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.front_proxy_crt[count.index].content
  ca_private_key_pem = data.tls_public_key.front_proxy_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.front_proxy_crt,
    data.tls_public_key.front_proxy_key
  ]
}

/*
  Front Proxy - CA Certificate: front-proxy-ca.crt
*/
data "tls_certificate" "front_proxy_crt" {
  count   = local.create_certificates
  content = trimspace(tls_self_signed_cert.front_proxy_crt[count.index].cert_pem)
}

output "front_proxy_crt" {
  description = "The contents of front-proxy.crt."
  value       = var.create_certificates ? trimspace(data.tls_certificate.front_proxy_crt[0].content) : null
  sensitive   = true
}

/*
  Front Proxy - Private Key: front-proxy-ca.key
*/
data "tls_public_key" "front_proxy_key" {
  count           = local.create_certificates
  private_key_pem = trimspace(tls_private_key.front_proxy_key[count.index].private_key_pem)
}

output "front_proxy_key" {
  description = "The contents of front-proxy.key."
  value       = var.create_certificates ? trimspace(data.tls_public_key.front_proxy_key[0].private_key_pem) : null
  sensitive   = true
}

/*
  Front Proxy - Private Key: front-proxy-ca.pub
*/
output "front_proxy_pub" {
  description = "The contents of front-proxy.pub."
  value       = var.create_certificates ? trimspace(data.tls_public_key.front_proxy_key[0].public_key_pem) : null
  sensitive   = true
}

/*
  Front Proxy - Client Certificate: front-proxy-client.crt
*/
data "tls_certificate" "front_proxy_client_crt" {
  count   = local.create_certificates
  content = trimspace(tls_locally_signed_cert.front_proxy_client_crt[count.index].cert_pem)
}

output "front_proxy_client_crt" {
  description = "The contents of front-proxy-client.crt."
  value       = var.create_certificates ? trimspace(data.tls_certificate.front_proxy_client_crt[0].content) : null
  sensitive   = true
}

/*
  Front Proxy - Client Private Key: front-proxy-client.key
*/
data "tls_public_key" "front_proxy_client_key" {
  count           = local.create_certificates
  private_key_pem = trimspace(tls_private_key.front_proxy_client_key[count.index].private_key_pem)
}

output "front_proxy_client_key" {
  description = "The contents of front-proxy-client.key."
  value       = var.create_certificates ? trimspace(data.tls_public_key.front_proxy_client_key[0].private_key_pem) : null
  sensitive   = true
}

/*
  Front Proxy - Client Publis Key: front-proxy-client.pub
*/
output "front_proxy_client_pub" {
  description = "The contents of front-proxy-client.pub."
  value       = var.create_certificates ? trimspace(data.tls_public_key.front_proxy_client_key[0].public_key_pem) : null
  sensitive   = true
}
