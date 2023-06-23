output "primary_certificates" {
  description = "The contents and destinations of the primary certificates."
  value       = var.create_certificates ? local.primary_cert_files : null
  sensitive   = true
}

output "etcd_certificates" {
  description = "The etcd certificates content and destination."
  value       = var.create_etcd_certificates ? local.etcd_cert_files : null
  sensitive   = true
}

output "all_certificates" {
  description = "All certificate content and destination of this module."
  value       = var.create_certificates || var.create_etcd_certificates ? local.all_cert_files : null
  sensitive   = true
}

output "all_certificates_destinations" {
  description = "The destination location(s) of the certificates."
  value       = var.create_certificates || var.create_etcd_certificates ? [for file in local.all_cert_files : file.destination] : null
}
