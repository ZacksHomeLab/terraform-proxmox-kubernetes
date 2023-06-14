/*
  Private Key: ca.key
*/
resource "tls_private_key" "ca_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  CA Certificate: ca.crt
*/
resource "tls_self_signed_cert" "ca_crt" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.ca_key[count.index].private_key_pem

  is_ca_certificate = true

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]

  dns_names = [
    local.cluster_name
  ]

  subject {
    common_name = local.cluster_name
  }

  depends_on = [
    data.tls_public_key.ca_key
  ]
}

data "tls_certificate" "ca_crt" {
  count   = local.create_certificates
  content = tls_self_signed_cert.ca_crt[count.index].cert_pem
}

data "tls_public_key" "ca_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.ca_key[count.index].private_key_pem
}

output "ca_crt" {
  description = "The contents of ca.crt."
  value       = trimspace(data.tls_certificate.ca_crt[0].content)
}

output "ca_key" {
  description = "The contents of ca.key and ca.pub."
  value       = trimspace(data.tls_public_key.ca_key[0].private_key_pem)
  sensitive   = true
}
