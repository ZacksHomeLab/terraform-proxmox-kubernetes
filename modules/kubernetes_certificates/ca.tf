/*
  Private Key: ca.key
*/
resource "tls_private_key" "ca_private_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  CA Certificate: ca.crt
*/
resource "tls_self_signed_cert" "ca_cert" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.ca_cert_public_key[count.index].private_key_pem

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
    data.tls_public_key.ca_cert_public_key
  ]
}

data "tls_certificate" "ca_cert" {
  count      = local.create_certificates
  content    = tls_self_signed_cert.ca_cert[count.index].cert_pem
  depends_on = [tls_self_signed_cert.ca_cert]
}

data "tls_public_key" "ca_cert_public_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.ca_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.ca_private_key]
}
