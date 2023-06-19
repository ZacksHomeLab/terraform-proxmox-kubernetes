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
  description = "The name of your Kubernetes Cluster. Default is 'kubernetes'."
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
  description = "The cluster's namespace. Default is 'default'"
  type        = string
  default     = "default"
}

variable "pod_network" {
  description = "Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node. Default value is 172.16.0.0/16"
  type        = string

  validation {
    condition     = can(regex("^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$", var.pod_network))
    error_message = "Invalid CIDR format. Please provide a valid CIDR address (e.g., 172.16.0.0/16)."
  }
  default = "172.16.0.0/16"
}

variable "service_network" {
  description = "Use alternative range of IP address for service VIPs. Default value is 10.96.0.0/12"
  type        = string

  validation {
    condition     = can(regex("^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$", var.service_network))
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
  description = "Defines the ability to deploy Pods on the Control Plane node. Typically done in small clusters. Default is false."
  type        = bool
  default     = true
}

variable "create_control_plane" {
  description = "Determines if Control Node should be created or destroyed."
  type        = bool
  default     = true
}

variable "control_plane_disks" {
  description = "The disk(s) settings for Control Plane Virtual Machine(s)."
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
}

variable "control_plane_networks" {
  description = "The network adapter(s) affiliated with Control Plane Node(s)."
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
}

variable "control_plane_settings" {
  description = "The settings for Control Plane Node(s)."
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
    vm_id            = optional(number)
  })
}

variable "control_plane_vm_name" {
  description = "The Control Plane Virtual Machine's name. This will also be its hostname."
  type        = string
  default     = "kube-plane"
}

variable "control_plane_target_node" {
  description = "The name of the target Proxmox node to host said Virtual Machine."
  type        = string
  default     = ""
}

variable "control_plane_template" {
  description = "The name of the Virtual Machine template to clone the Virtual Machine from."
  type        = string
  default     = ""
}

variable "control_plane_storage" {
  description = "The name of the storage location in Proxmox to house said Virtual Machine(s)."
  type        = string
  default     = ""
}

variable "control_plane_count" {
  description = "The amount of Control Plane(s) Virtual Machine(s) to be created."
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "The amount of Worker Node(s) Virtual Machine(s) to be created."
  type        = number

  validation {
    condition     = var.worker_count >= 0
    error_message = "Please choose a number equal or greater than 0."
  }

  default = 0
}

variable "create_worker" {
  description = "Determines if Worker Node(s) should be created or destroyed."
  type        = bool
  default     = true
}

variable "worker_settings" {
  description = "The settings for Worker Node(s)."
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
    description      = optional(string, "This Virtual Machine hosts K8's Worker Node.")
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
    vm_id            = optional(number)
  })
}

variable "worker_disks" {
  description = "The disk(s) of the Worker Node(s)."
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
}

variable "worker_networks" {
  description = "The network adapters affiliated with the Worker Node(s)."
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
}

variable "worker_vm_name" {
  description = "The Control Plane Virtual Machine's name. This will also be its hostname."
  type        = string
  default     = "worker"
}

variable "worker_template" {
  description = "The name of the Virtual Machine template to clone the Virtual Machine from."
  type        = string
  default     = ""
}

variable "worker_target_node" {
  description = "The name of the target Proxmox node to host said Virtual Machine."
  type        = string
  default     = ""
}

variable "worker_storage" {
  description = "The name of the storage location in Proxmox to house said Virtual Machine(s)."
  type        = string
  default     = ""
}

variable "settings" {
  description = "The default settings for Virtual Machine(s)."
  type = object({
    automatic_reboot = optional(bool, true)
    balloon          = optional(number, 0)
    bios             = optional(string, "seabios")
    cicustom         = optional(string, "")
    cipassword       = optional(string)
    ciuser           = optional(string)
    ciwait           = optional(number, 30)
    cores            = optional(number, 2)
    cpu              = optional(string, "host")
    description      = optional(string, "This is a Virtual Machine!")
    hotplug          = optional(string, "cpu,network,disk,usb")
    memory           = optional(number, 2048)
    nameserver       = optional(string, "")
    onboot           = optional(bool, true)
    oncreate         = optional(bool, true)
    pool             = optional(string, "")
    scsihw           = optional(string, "virtio-scsi-pci")
    searchdomain     = optional(string, "")
    sshkeys          = optional(string, "")
    sockets          = optional(number, 1)
    tags             = optional(list(string), [])
    vm_id            = optional(number, 0)
  })

  validation {
    condition     = var.settings.vm_id != 0
    error_message = "To set a default vm_id, you must set it to 0."
  }
}

variable "disks" {
  description = "The default disk(s) for all Virtual Machines."
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
}

variable "networks" {
  description = "The network adapter(s) affiliated with the Control Plane Virtual Machine(s)."
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
}

variable "target_node" {
  description = "The default target node for all Virtual Machines."
  type        = string
}

variable "template" {
  description = "The default name of the Virtual Machine template to clone the Virtual Machine from."
  type        = string
}

variable "storage" {
  description = "The default storage location to house said Virtual Machine(s)."
  type        = string
}
