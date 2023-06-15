output "primary_certificates" {
  value     = var.create_certificates ? local.primary_cert_files : null
  sensitive = true
}

output "etcd_certificates" {
  value     = var.create_etcd_certificates ? local.etcd_cert_files : null
  sensitive = true
}

output "all_certificates" {
  value     = var.create_certificates || var.create_etcd_certificates ? local.all_cert_files : null
  sensitive = true
}
