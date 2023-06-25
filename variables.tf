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

variable "cluster_name" {
  description = "(String) The name of your Kubernetes Cluster. Default is 'kubernetes'."
  type        = string
  default     = "kubernetes"
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

variable "pod_network" {
  description = "(String) Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node. Default value is 172.16.0.0/16"
  type        = string

  validation {
    condition     = can(regex("^\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.pod_network))
    error_message = "Invalid CIDR format. Please provide a valid CIDR address (e.g., 172.16.0.0/16)."
  }
  default = "172.16.0.0/16"
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

/*
variable "external_lb_on_control_plane" {
  description = "(Bool) Defines the ability to deploy an External Load Balancer on each Control Plane. Default is true."
  type        = bool
  default     = true
}*/

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

  default = "192.168.2.100/24"
}

variable "apiserver_src_port" {
  description = "(String) The default source port that apiserver will listen on. Default is 6443."
  type        = number

  validation {
    condition     = var.apiserver_src_port > 0
    error_message = "Invalid Port. Please provide a valid port number."
  }

  default = 6443
}

variable "apiserver_dest_port" {
  description = "(String) The default destination port the apiserver will liste on. Default is 8443."
  type        = number

  validation {
    condition     = var.apiserver_dest_port > 0
    error_message = "Invalid Port. Please provide a valid port number."
  }

  default = 8443
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

variable "ext_apiserver_lb_count" {
  description = "(Number) The number of External API Server Load balancer Virtual Machine(s) to create. If you use this functionality, at least have two."
  type        = number

  validation {
    condition     = var.ext_apiserver_lb_count >= 0
    error_message = "Please choose a number equal or greater than 0."
  }

  default = 0
}

variable "ext_apiserver_lb_disks" {
  description = "[List{Object}] The disk(s) settings for External API Server Load Balancer(s)."
  type = list(object({
    storage            = optional(string)
    size               = optional(string)
    type               = optional(string)
    format             = optional(string)
    cache              = optional(string)
    backup             = optional(bool)
    iothread           = optional(number)
    discard            = optional(number)
    replicate          = optional(number)
    ssd                = optional(number)
    mbps               = optional(number)
    mbps_rd            = optional(number)
    mbps_rd_max        = optional(number)
    mbps_wr            = optional(number)
    mbps_wr_max        = optional(number)
    iops               = optional(number)
    iops_rd            = optional(number)
    iops_rd_max        = optional(number)
    iops_rd_max_length = optional(number)
    iops_wr            = optional(number)
    iops_wr_max        = optional(number)
    iops_wr_max_length = optional(number)
  }))

  default = []
}

variable "ext_apiserver_lb_networks" {
  description = "[List{Object}] The network adapter(s) affiliated with the External API Server Load Balancer(s)."
  type = list(object({
    bridge    = optional(string)
    model     = optional(string)
    gateway   = optional(string)
    gateway6  = optional(string)
    ip        = optional(string)
    ip6       = optional(string)
    dhcp      = optional(bool)
    dhcp6     = optional(bool)
    firewall  = optional(bool)
    link_down = optional(bool)
    macaddr   = optional(string)
    queues    = optional(number)
    rate      = optional(number)
    vlan_tag  = optional(number)
  }))

  default = []
}

variable "ext_apiserver_lb_settings" {
  description = "{Object} The settings for an External API Server Load Balancer(s)."
  type = object({
    automatic_reboot = optional(bool)
    balloon          = optional(number)
    bios             = optional(string)
    cicustom         = optional(string)
    cipassword       = optional(string)
    ciuser           = optional(string)
    ciwait           = optional(number)
    cores            = optional(number)
    cpu              = optional(string)
    description      = optional(string, "This Virtual Machine hosts an External API Server Load Balancer")
    hotplug          = optional(string)
    memory           = optional(number)
    nameserver       = optional(string)
    onboot           = optional(bool)
    oncreate         = optional(bool)
    pool             = optional(string)
    scsihw           = optional(string)
    searchdomain     = optional(string)
    sshkeys          = optional(string)
    sockets          = optional(number)
    tags             = optional(list(string))
    target_node      = optional(string)
    template         = optional(string)
    vm_name          = optional(string, "k8-api-lb")
    vm_id            = optional(number)
  })

  default = {}
}

variable "create_control_plane" {
  description = "(Bool) Determines if Control Node should be created or destroyed."
  type        = bool
  default     = true
}

variable "control_plane_disks" {
  description = "[List{Object}] The disk(s) settings for Control Plane Virtual Machine(s)."
  type = list(object({
    storage            = optional(string)
    size               = optional(string)
    type               = optional(string)
    format             = optional(string)
    cache              = optional(string)
    backup             = optional(bool)
    iothread           = optional(number)
    discard            = optional(number)
    replicate          = optional(number)
    ssd                = optional(number)
    mbps               = optional(number)
    mbps_rd            = optional(number)
    mbps_rd_max        = optional(number)
    mbps_wr            = optional(number)
    mbps_wr_max        = optional(number)
    iops               = optional(number)
    iops_rd            = optional(number)
    iops_rd_max        = optional(number)
    iops_rd_max_length = optional(number)
    iops_wr            = optional(number)
    iops_wr_max        = optional(number)
    iops_wr_max_length = optional(number)
  }))

  default = []
}

variable "control_plane_networks" {
  description = "[List{Object}] The network adapter(s) affiliated with Control Plane Node(s)."
  type = list(object({
    bridge    = optional(string)
    model     = optional(string)
    gateway   = optional(string)
    gateway6  = optional(string)
    ip        = optional(string)
    ip6       = optional(string)
    dhcp      = optional(bool)
    dhcp6     = optional(bool)
    firewall  = optional(bool)
    link_down = optional(bool)
    macaddr   = optional(string)
    queues    = optional(number)
    rate      = optional(number)
    vlan_tag  = optional(number)
  }))

  default = []
}

variable "control_plane_settings" {
  description = "{Object} The settings for Control Plane Node(s)."
  type = object({
    automatic_reboot = optional(bool)
    balloon          = optional(number)
    bios             = optional(string)
    cicustom         = optional(string)
    cipassword       = optional(string)
    ciuser           = optional(string)
    ciwait           = optional(number)
    cores            = optional(number)
    cpu              = optional(string)
    description      = optional(string, "This Virtual Machine hosts K8's Control Pane.")
    hotplug          = optional(string)
    memory           = optional(number)
    nameserver       = optional(string)
    onboot           = optional(bool)
    oncreate         = optional(bool)
    pool             = optional(string)
    scsihw           = optional(string)
    searchdomain     = optional(string)
    sshkeys          = optional(string)
    sockets          = optional(number)
    tags             = optional(list(string))
    target_node      = optional(string)
    template         = optional(string)
    vm_name          = optional(string, "k8-plane")
    vm_id            = optional(number)
  })

  default = {}
}

variable "control_plane_count" {
  description = "(Number) The amount of Control Plane(s) Virtual Machine(s) to be created."
  type        = number

  validation {
    condition     = var.control_plane_count >= 0
    error_message = "Please choose a number equal or greater than 0."
  }

  default = 1
}

variable "worker_count" {
  description = "(Number) The amount of Worker Node(s) Virtual Machine(s) to be created."
  type        = number

  validation {
    condition     = var.worker_count >= 0
    error_message = "Please choose a number equal or greater than 0."
  }

  default = 0
}

variable "create_worker" {
  description = "(Bool) Determines if Worker Node(s) should be created or destroyed."
  type        = bool
  default     = true
}

variable "worker_settings" {
  description = "{Object} The settings for Worker Node(s)."
  type = object({
    automatic_reboot = optional(bool)
    balloon          = optional(number)
    bios             = optional(string)
    cicustom         = optional(string)
    cipassword       = optional(string)
    ciuser           = optional(string)
    ciwait           = optional(number)
    cores            = optional(number)
    cpu              = optional(string)
    description      = optional(string, "This Virtual Machine is a K8 Worker Node.")
    hotplug          = optional(string)
    memory           = optional(number)
    nameserver       = optional(string)
    onboot           = optional(bool)
    oncreate         = optional(bool)
    pool             = optional(string)
    scsihw           = optional(string)
    searchdomain     = optional(string)
    sshkeys          = optional(string)
    sockets          = optional(number)
    tags             = optional(list(string))
    target_node      = optional(string)
    template         = optional(string)
    vm_name          = optional(string, "k8-worker")
    vm_id            = optional(number)
  })

  default = {}
}

variable "worker_disks" {
  description = "[List{Object}] The disk(s) of the Worker Node(s)."
  type = list(object({
    storage            = optional(string)
    size               = optional(string)
    type               = optional(string)
    format             = optional(string)
    cache              = optional(string)
    backup             = optional(bool)
    iothread           = optional(number)
    discard            = optional(number)
    replicate          = optional(number)
    ssd                = optional(number)
    mbps               = optional(number)
    mbps_rd            = optional(number)
    mbps_rd_max        = optional(number)
    mbps_wr            = optional(number)
    mbps_wr_max        = optional(number)
    iops               = optional(number)
    iops_rd            = optional(number)
    iops_rd_max        = optional(number)
    iops_rd_max_length = optional(number)
    iops_wr            = optional(number)
    iops_wr_max        = optional(number)
    iops_wr_max_length = optional(number)
  }))

  default = []
}

variable "worker_networks" {
  description = "[List{Object}] The network adapters affiliated with the Worker Node(s)."
  type = list(object({
    bridge    = optional(string)
    model     = optional(string)
    gateway   = optional(string)
    gateway6  = optional(string)
    ip        = optional(string)
    ip6       = optional(string)
    dhcp      = optional(bool)
    dhcp6     = optional(bool)
    firewall  = optional(bool)
    link_down = optional(bool)
    macaddr   = optional(string)
    queues    = optional(number)
    rate      = optional(number)
    vlan_tag  = optional(number)
  }))

  default = []
}

variable "settings" {
  description = "{Object} The default settings for Virtual Machine(s)."
  type = object({
    automatic_reboot = optional(bool, true)
    balloon          = optional(number, 0)
    bios             = optional(string, "seabios")
    cicustom         = optional(string)
    cipassword       = optional(string)
    ciuser           = optional(string)
    ciwait           = optional(number, 30)
    cores            = optional(number, 1)
    cpu              = optional(string, "host")
    description      = optional(string, "This is a Virtual Machine.")
    hotplug          = optional(string, "cpu,network,disk,usb")
    memory           = optional(number, 2048)
    nameserver       = optional(string)
    onboot           = optional(bool)
    oncreate         = optional(bool)
    pool             = optional(string)
    scsihw           = optional(string, "virtio-scsi-pci")
    searchdomain     = optional(string)
    sshkeys          = optional(string)
    sockets          = optional(number, 1)
    tags             = optional(list(string))
    vm_id            = optional(number, 0)
  })

  default = {}
}

variable "disks" {
  description = "[List{Object}] The default disk(s) for all Virtual Machines."
  type = list(object({
    storage            = optional(string)
    size               = optional(string, "10G")
    type               = optional(string, "virtio")
    format             = optional(string, "raw")
    cache              = optional(string, "none")
    backup             = optional(bool, false)
    iothread           = optional(number, 0)
    discard            = optional(number, 0)
    replicate          = optional(number, 0)
    ssd                = optional(number, 0)
    mbps               = optional(number, 0)
    mbps_rd            = optional(number, 0)
    mbps_rd_max        = optional(number, 0)
    mbps_wr            = optional(number, 0)
    mbps_wr_max        = optional(number, 0)
    iops               = optional(number, 0)
    iops_rd            = optional(number, 0)
    iops_rd_max        = optional(number, 0)
    iops_rd_max_length = optional(number, 0)
    iops_wr            = optional(number, 0)
    iops_wr_max        = optional(number, 0)
    iops_wr_max_length = optional(number, 0)
  }))

  default = []
}

variable "networks" {
  description = "[List{Object}] The network adapter(s) affiliated with the Control Plane Virtual Machine(s)."
  type = list(object({
    bridge    = optional(string, "vmbr0")
    model     = optional(string, "virtio")
    gateway   = optional(string)
    gateway6  = optional(string)
    ip        = optional(string)
    ip6       = optional(string)
    dhcp      = optional(bool, false)
    dhcp6     = optional(bool, false)
    firewall  = optional(bool, false)
    link_down = optional(bool, false)
    macaddr   = optional(string)
    queues    = optional(number, 1)
    rate      = optional(number, 0)
    vlan_tag  = optional(number, -1)
  }))

  default = []
}

variable "target_node" {
  description = "(String) The default target node for all Virtual Machines."
  type        = string
}

variable "template" {
  description = "(String) The default name of the Virtual Machine template to clone the Virtual Machine from."
  type        = string
}
