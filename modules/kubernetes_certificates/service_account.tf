/*
  Service Account - Private Key: sa.key
*/
resource "tls_private_key" "sa_key" {
  count     = local.create_certificates
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
  Service Account - Private Key: sa.key
*/
data "tls_public_key" "sa_key" {
  count           = local.create_certificates
  private_key_pem = tls_private_key.sa_key[count.index].private_key_pem
}

output "sa_key" {
  description = "The contents of sa.key."
  value       = var.create_certificates ? data.tls_public_key.sa_key[0].private_key_pem : null
  sensitive   = true
}

/*
  Service Account - Public Key: sa.pub
*/
output "sa_pub" {
  description = "The contents of sa.pub."
  value       = var.create_certificates ? data.tls_public_key.sa_key[0].public_key_pem : null
  sensitive   = true
}
