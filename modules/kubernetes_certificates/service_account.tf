/*
  Service Account - Private Key: sa.key
*/
resource "tls_private_key" "sa_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Service Account - Public Key: sa.pub

  Access the PUblic Key SHA256 by passing:
    data.tls_public_key.sa_pub.public_key_fingerprint_sha256
*/
data "tls_public_key" "sa_pub" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.sa_key[count.index].private_key_pem
}

output "sa_key" {
  description = "The contents of sa.key and sa.pub."
  value       = trimspace(data.tls_public_key.sa_pub[0].private_key_pem)
  sensitive   = true
}
