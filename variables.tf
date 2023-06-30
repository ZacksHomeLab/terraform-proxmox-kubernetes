variable "apiserver_lb_type" {
  description = "(String) The type of load balancer to use for the API Server. Valid values are 'haproxy' and 'kube-vip'. Default is 'haproxy'."
  type        = string

  validation {
    condition     = contains(["haproxy", "kube-vip"], var.apiserver_lb_type)
    error_message = "Invalid load balancer type. Valid values are 'haproxy' and 'kube-vip'."
  }

  default = "haproxy"
}

variable "create_apiserver_lb" {
  description = "(Bool) Whether to create an API Server Load Balancer on each Control Plane(s). Default is true."
  type        = bool
  default     = true
}

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

variable "cluster_domain" {
  description = "The domain of your cluster (e.g., mycompany.local). Default is 'cluster.local'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.cluster_domain))
    error_message = "Invalid domain format. Please provide a valid domain."
  }

  default = "cluster.local"
}

variable "cluster_namespace" {
  description = "(String) The cluster's namespace. Default is 'default'"
  type        = string
  default     = "default"
}

/*
variable "deploy_apiserver_lb_on_os" {
  description = "(Bool) Whether to deploy the API Server Load balancer on the Operating System or as a Pod(s). Default is false (i.e., deploy as a Pod(s))."
  type        = bool
  default     = false
}*/

variable "pod_network" {
  description = "(String) Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node. Default value is 10.244.0.0/16"
  type        = string

  validation {
    condition     = can(regex("^\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.pod_network))
    error_message = "Invalid CIDR format. Please provide a valid CIDR address (e.g., 10.244.0.0/16)."
  }
  default = "10.244.0.0/16"
}

variable "service_network" {
  description = "(String) Use alternative range of IP address for service VIPs. Default value is 10.96.0.0/12"
  type        = string

  validation {
    condition     = can(regex("^\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.service_network))
    error_message = "Invalid CIDR format. Please provide a valid CIDR address (e.g., 10.96.0.0/12)."
  }
  default = "10.96.0.0/12"
}

variable "private_key" {
  description = "The private key file to connect to said Virtual Machine."
  type        = string
  sensitive   = true
  default     = null
}

variable "pods_on_control_plane" {
  description = "(Bool) Defines the ability to deploy Pods on the Control Plane node. Typically done in small clusters. Default is false."
  type        = bool
  default     = true
}

variable "apiserver_lb_virtual_ip" {
  description = "(String) The Virtual IP address (in CIDR-Notation) the load balancer will listen on. Note: This must be a routable IP that the Control Plane can access. Default is 192.168.2.100/24"
  type        = string

  validation {
    condition     = can(regex("^\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.apiserver_lb_virtual_ip))
    error_message = "Invalid CIDR format. Please provide a valid CIDR address (e.g., 192.168.2.100/24)."
  }

  default = "192.168.2.120/24"
}

variable "apiserver_lb_port" {
  description = "(String) The default port for the Apiserver LB will listen on. Default is 6443."
  type        = number

  validation {
    condition     = var.apiserver_lb_port > 0
    error_message = "Invalid Port. Please provide a valid port number."
  }

  default = 6443
}

variable "apiserver_dest_port" {
  description = "(String) The default destination port the apiserver will liste on. Default is 6443."
  type        = number

  validation {
    condition     = var.apiserver_dest_port > 0
    error_message = "Invalid Port. Please provide a valid port number."
  }

  default = 6443
}

variable "keepalive_router_id" {
  description = "(Number) The Router ID for Keepalive. You would change this number if you have multiple clusters using this module and Keepalive. Default is 51."
  type        = number

  validation {
    condition     = var.keepalive_router_id > 0
    error_message = "Please select a number greater than zero."
  }
  default = 51
}

variable "create_ext_apiserver_lb" {
  description = "(Bool) Determines if an External API Server Load Balancer should be created or destroyed."
  type        = bool
  default     = false
}

variable "create_control_plane" {
  description = "(Bool) Determines if Control Node should be created or destroyed."
  type        = bool
  default     = true
}

variable "create_worker" {
  description = "(Bool) Determines if Worker Node(s) should be created or destroyed."
  type        = bool
  default     = true
}

variable "etcd_src_port" {
  description = "(Number) The source port for etcd. Default is 2379."
  type        = number

  validation {
    condition     = var.etcd_src_port > 0
    error_message = "Please select a number greater than zero."
  }

  default = 2379
}

variable "etcd_dest_port" {
  description = "(Number) The destination port for etcd. Default is 2380."
  type        = number

  validation {
    condition     = var.etcd_dest_port > 0
    error_message = "Please select a number greater than zero."
  }

  default = 2380
}
