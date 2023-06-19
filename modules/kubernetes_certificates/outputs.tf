output "primary_certificates" {
  value = var.create_certificates ? local.primary_cert_files : null
}

output "etcd_certificates" {
  value = var.create_etcd_certificates ? local.etcd_cert_files : null
}

output "all_certificates" {
  value = var.create_certificates || var.create_etcd_certificates ? local.all_cert_files : null
}
