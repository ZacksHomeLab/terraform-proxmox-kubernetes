/*
  API Server - Server Certificate Private Key: apiserver.key
*/
resource "tls_private_key" "api_server_ca_private_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Server Certificate CSR
*/
resource "tls_cert_request" "api_server_ca_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.api_server_ca_cert_public_key[count.index].private_key_pem

  subject {
    common_name = local.api_server_name
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
    data.tls_public_key.api_server_ca_cert_public_key
  ]
}

/*
  API Server - Server Certificate: apiserver.crt
*/
resource "tls_locally_signed_cert" "api_server_ca_cert" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.api_server_ca_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.ca_cert_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]

  depends_on = [
    data.tls_certificate.ca_cert,
    data.tls_public_key.ca_cert_public_key
  ]
}

/*
  API Server - Client Certificate Private Key: apiserver-kubelet-client.key
*/
resource "tls_private_key" "api_server_client_private_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Client Certificate CSR
*/
resource "tls_cert_request" "api_server_client_csr" {
  count           = local.create_certificates
  private_key_pem = data.tls_public_key.api_server_client_cert_public_key[count.index].private_key_pem

  subject {
    common_name  = local.api_server_kubelet_client_cn
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.api_server_client_cert_public_key
  ]
}


/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
resource "tls_locally_signed_cert" "api_server_client_cert" {
  count              = local.create_certificates
  cert_request_pem   = tls_cert_request.api_server_client_csr[count.index].cert_request_pem
  ca_cert_pem        = data.tls_certificate.ca_cert[count.index].content
  ca_private_key_pem = data.tls_public_key.ca_cert_public_key[count.index].private_key_pem

  is_ca_certificate = false

  early_renewal_hours   = local.early_renewal_hours
  validity_period_hours = local.validity_period_hours

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth"
  ]

  depends_on = [
    data.tls_certificate.ca_cert,
    data.tls_public_key.ca_cert_public_key
  ]
}

/*
  API Server - Etcd Client Certificate Private Key: apiserver-etcd-client.key
*/
resource "tls_private_key" "api_server_etcd_client_private_key" {
  count     = local.create_etcd_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  API Server - Etcd Client Certificate CSR
*/
resource "tls_cert_request" "api_server_etcd_client_csr" {
  count           = local.create_etcd_certificates
  private_key_pem = data.tls_public_key.api_server_etcd_client_cert_public_key[count.index].private_key_pem

  subject {
    common_name  = local.api_server_kubelet_client_cn
    organization = "system:masters"
  }

  depends_on = [
    data.tls_public_key.api_server_etcd_client_cert_public_key
  ]
}

/*
  API Server - Etcd Client Certificate: apiserver-etcd-client.crt
*/
resource "tls_locally_signed_cert" "api_server_etcd_client_cert" {
  count              = local.create_etcd_certificates
  cert_request_pem   = tls_cert_request.api_server_etcd_client_csr[count.index].cert_request_pem
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
  API Server - Server Certificate: apiserver.crt
*/
data "tls_certificate" "api_server_ca_cert" {
  count      = local.create_certificates
  depends_on = [tls_locally_signed_cert.api_server_ca_cert]
  content    = tls_locally_signed_cert.api_server_ca_cert[count.index].cert_pem
}

/*
  API Server - Server Certificate Private Key: apiserver.key
*/
data "tls_public_key" "api_server_ca_cert_public_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.api_server_ca_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.api_server_ca_private_key]
}

/*
  API Server - Client Certificate: apiserver-kubelet-client.crt
*/
data "tls_certificate" "api_server_client_cert" {
  count      = local.create_certificates
  content    = tls_locally_signed_cert.api_server_client_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.api_server_client_cert]
}

/*
  API Server - Client Certificate Private Key: apiserver-kubelet-client.key
*/
data "tls_public_key" "api_server_client_cert_public_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.api_server_client_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.api_server_client_private_key]
}

/*
  API Server - Etcd Client Certificate: apiserver-etcd-client.crt
*/
data "tls_certificate" "api_server_etcd_client_cert" {
  count      = local.create_etcd_certificates
  content    = tls_locally_signed_cert.api_server_etcd_client_cert[count.index].cert_pem
  depends_on = [tls_locally_signed_cert.api_server_etcd_client_cert]
}

/*
  API Server - Etcd Client Certificate Private Key: apiserver-etcd-client.key
*/
data "tls_public_key" "api_server_etcd_client_cert_public_key" {
  count           = local.create_etcd_certificates
  private_key_pem = tls_private_key.api_server_etcd_client_private_key[count.index].private_key_pem
  depends_on      = [tls_private_key.api_server_etcd_client_private_key]
}

