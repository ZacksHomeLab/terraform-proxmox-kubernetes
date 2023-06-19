/*
  The purpose of a token is to generate a password that
    Control Plane(s), Worker(s), and other services can
    use to join said Cluster(s).
*/
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
