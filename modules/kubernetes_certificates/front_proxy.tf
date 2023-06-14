/*
  Front Proxy - Private Key: front-proxy-ca.key
*/
resource "tls_private_key" "front_proxy_ca_private_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - CA Certificate: front-proxy-ca.crt
*/
resource "tls_self_signed_cert" "front_proxy_ca_cert" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.front_proxy_ca_public_key[count.index].private_key_pem

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
    data.tls_public_key.front_proxy_ca_public_key
  ]
}

/*
  Front Proxy - Client Private Key: front-proxy-client.key
*/
resource "tls_private_key" "front_proxy_client_private_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Front Proxy - Client Certificate CSR
*/
resource "tls_cert_request" "front_proxy_client_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.front_proxy_client_cert_public_key[count.index].private_key_pem

  subject {
    common_name = local.front_proxy_client_name
  }

  depends_on = [
    data.tls_public_key.front_proxy_client_cert_public_key
  ]
}

/*
  Front Proxy - Client Certificate: front-proxy-client.crt
*/
resource "tls_locally_signed_cert" "front_proxy_client_cert" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.front_proxy_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.front_proxy_ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.front_proxy_ca_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.front_proxy_ca_cert,
    data.tls_public_key.front_proxy_ca_public_key
  ]
}

data "tls_certificate" "front_proxy_ca_cert" {
  count      = local.create_certificates
  content    = tls_self_signed_cert.front_proxy_ca_cert[count.index].cert_pem
  depends_on = [tls_self_signed_cert.front_proxy_ca_cert]
}

data "tls_public_key" "front_proxy_ca_public_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.front_proxy_ca_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.front_proxy_ca_private_key]
}

data "tls_certificate" "front_proxy_client_cert" {
  count      = local.create_certificates
  content    = tls_locally_signed_cert.front_proxy_client_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.front_proxy_client_cert]
}

data "tls_public_key" "front_proxy_client_cert_public_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.front_proxy_client_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.front_proxy_client_private_key]
}
