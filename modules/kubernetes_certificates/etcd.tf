/*
  etcd - CA Certificate Private Key: etcd/ca.key
*/
resource "tls_private_key" "etcd_ca_private_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd - CA Certificate: etcd/ca.crt
*/
resource "tls_self_signed_cert" "etcd_ca_cert" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_ca_cert_public_key[count.index].private_key_pem

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
    data.tls_public_key.etcd_ca_cert_public_key
  ]
}


/*
  etcd Healthcheck Client - Certificate Private Key: etcd/healthcheck-client.key
*/
resource "tls_private_key" "healthcheck_client_private_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Healthcheck Client - Certificate CSR
*/
resource "tls_cert_request" "healthcheck_client_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.healthcheck_client_cert_public_key[count.index].private_key_pem

  subject {
    common_name  = local.etcd_healthcheck_name
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.healthcheck_client_cert_public_key
  ]
}

/*
  etcd Healthcheck Client - Certificate: etcd/healthcheck-client.crt
*/
resource "tls_locally_signed_cert" "healthcheck_client_cert" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.healthcheck_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_cert_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_cert,
    data.tls_public_key.etcd_ca_cert_public_key
  ]
}

/*
  etcd Peer - Certificate Private Key: etcd/peer.key
*/
resource "tls_private_key" "etcd_peer_private_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Peer - Certificate CSR
*/
resource "tls_cert_request" "etcd_peer_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_peer_cert_public_key[count.index].private_key_pem

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
    data.tls_public_key.etcd_peer_cert_public_key
  ]
}

/*
  etcd Peer - Certificate: etcd/peer.crt
*/
resource "tls_locally_signed_cert" "etcd_peer_cert" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_peer_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_cert_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_cert,
    data.tls_public_key.etcd_ca_cert_public_key
  ]
}

/*
  etcd Server - Certificate Private Key: etcd/server.key
*/
resource "tls_private_key" "etcd_server_private_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  etcd Server - Certificate CSR
*/
resource "tls_cert_request" "etcd_server_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.etcd_server_cert_public_key[count.index].private_key_pem

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
    data.tls_public_key.etcd_server_cert_public_key
  ]
}

/*
  etcd Peer - Certificate: etcd/server.crt
*/
resource "tls_locally_signed_cert" "etcd_server_cert" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.etcd_server_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.etcd_ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.etcd_ca_cert_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "server_auth",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.etcd_ca_cert,
    data.tls_public_key.etcd_ca_cert_public_key
  ]
}

data "tls_certificate" "etcd_ca_cert" {
  count      = local.create_etcd_certificates
  content    = tls_self_signed_cert.etcd_ca_cert[count.index].cert_pem
  depends_on = [tls_self_signed_cert.etcd_ca_cert]
}

data "tls_public_key" "etcd_ca_cert_public_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_ca_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.etcd_ca_private_key]
}

data "tls_certificate" "healthcheck_client_cert" {
  count      = local.create_etcd_certificates
  content    = tls_locally_signed_cert.healthcheck_client_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.healthcheck_client_cert]
}

data "tls_public_key" "healthcheck_client_cert_public_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.healthcheck_client_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.healthcheck_client_private_key]
}

data "tls_certificate" "etcd_peer_cert" {
  count      = local.create_etcd_certificates
  content    = tls_locally_signed_cert.etcd_peer_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.etcd_peer_cert]
}

data "tls_public_key" "etcd_peer_cert_public_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_peer_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.etcd_peer_private_key]
}

data "tls_certificate" "etcd_server_cert" {
  count      = local.create_etcd_certificates
  content    = tls_locally_signed_cert.etcd_server_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.etcd_server_cert]
}

data "tls_public_key" "etcd_server_cert_public_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.etcd_server_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.etcd_server_private_key]
}
