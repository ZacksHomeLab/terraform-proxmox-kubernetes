resource "random_string" "prefix" {
  length  = 6
  upper   = false
  special = false

  lifecycle {
    ignore_changes = [
      length,
      special,
      upper,
    ]
  }
}

resource "random_string" "suffix" {
  length  = 16
  upper   = false
  special = false

  lifecycle {
    ignore_changes = [
      length,
      special,
      upper,
    ]
  }
}

output "kube_token" {
  value     = "${random_string.prefix.result}.${random_string.suffix.result}"
  sensitive = true
}
