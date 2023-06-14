variable "create_certificates" {
  description = "(Bool) Whether Terraform should generate the necessary certificates. Default is true."
  type        = bool
  default     = true
}

variable "create_etcd_certificates" {
  description = <<-EOT
    "(Bool) Whether Terraform should generate the necessary certificates for etcd.
    You would disable this functionality if you were to use a service other than etcd.

    Default is true."
  EOT
  type        = bool
  default     = true
}

variable "control_plane_name" {
  description = "(String) The name of the Control Plane. This can be the machine's name."
  type        = string
}

variable "cluster_name" {
  description = "(String) The name of your Kubernetes Cluster. Default is 'kubernetes'."
  type        = string
  nullable    = false
  default     = "kubernetes"
}

variable "cluster_domain" {
  description = "(String) The domain name of your cluster (e.g., mycompany.local). Default is 'cluster.local'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.cluster_domain))
    error_message = "Invalid domain format. Please provide a valid domain (e.g., cluster.local)."
  }

  default = "cluster.local"
}

variable "cluster_namespace" {
  description = "(String) The cluster's namespace. Default is 'default'"
  type        = string
  nullable    = false
  default     = "default"
}

variable "api_server_name" {
  description = "(String) The name of the Kubernetes API Server. Default is 'kube-apiserver'."
  type        = string
  nullable    = false
  default     = "kube-apiserver"
}

variable "api_server_client_name" {
  description = "(String) The name of the Kubernetes API Server Client Certificate. Default is 'kube-apiserver-kubelet-client'."
  type        = string
  nullable    = false
  default     = "kube-apiserver-kubelet-client"
}

variable "front_proxy_name" {
  description = "(String) The Name of the Kubernetes Front Proxy CA Certificate. Default is 'front-proxy-ca'."
  type        = string
  nullable    = false
  default     = "front-proxy-ca"
}

variable "front_proxy_client_name" {
  description = "(String) The Name of the Kubernetes Front Proxy Client Certificate. Default is 'front-proxy-client'."
  type        = string
  nullable    = false
  default     = "front-proxy-client"
}

variable "etcd_name" {
  description = "(String) The Name of the Kubernetes etcd Server. Default is 'etcd-ca'."
  type        = string
  nullable    = false
  default     = "etcd-ca"
}

variable "etcd_healthcheck_name" {
  description = "(String) The Name of the etcd healthcheck certificate. Default is 'kube-etcd-healthcheck-client'."
  type        = string
  nullable    = false
  default     = "kube-etcd-healthcheck-client"
}

variable "etcd_api_server_client_name" {
  description = "(String) The Name of the certificate the apiserver uses to access etcd. Default is 'kube-apiserver-etcd-client'."
  type        = string
  nullable    = false
  default     = "kube-apiserver-etcd-client"
}

variable "early_renewal_hours" {
  description = <<-EOT
    (Number) The resource will consider the certificate to have expired the given number of hours before its actual expiry time.
    This can be useful to deploy an updated certificate in advance of the expiration of the current certificate.
    However, the old certificate remains valid until its true expiration time, since this resource does not (and cannot) support certificate revocation.

    Default is 740.
  EOT
  type        = number
  default     = 740

  validation {
    condition     = var.early_renewal_hours >= 0
    error_message = "Invalid number format. Please choose a number equal or greater than 0."
  }
}

variable "validity_period_hours" {
  description = "(Number) Number of hours, after initial issuing, that the certificate will remain valid for. Default is 87600."
  type        = number

  validation {
    condition     = var.validity_period_hours > 0
    error_message = "Invalid number format. Please choose a number greater than 0."
  }

  default = 87600
}

variable "internal_control_plane_ip" {
  description = "(String) The Internal IP Address of the Control Plane."
  type        = string

  validation {
    condition     = can(regex("^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$", var.internal_control_plane_ip))
    error_message = "Invalid IP Address. Please provide an IP Address that meets IPv4 CIDR-Notation (e.g., 192.168.1.1)."
  }
}

variable "external_control_plane_ip" {
  description = "(String) The External IP Address of the Control Plane."
  type        = string

  validation {
    condition     = can(regex("^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$", var.external_control_plane_ip))
    error_message = "Invalid IP Address. Please provide an IP Address that meets IPv4 CIDR-Notation (e.g., 192.168.1.1)."
  }
}
