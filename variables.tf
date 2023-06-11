variable "enable_deploy_on_control_node" {
  description = "Defines the ability to deploy Pods on the Control Plane node. Typically done in small clusters. Default is false."
  type        = bool
  default     = true
}

variable "enable_deploy_on_master_node" {
  description = "Defines the ability to deploy Pods on the Master node(s). Typically done in small clusters. Default is false."
  type        = bool
  default     = false
}

variable "create_control_node" {
  description = "Determines if Control Node should be created or destroyed."
  type        = bool
  default     = true
}

variable "control_node_settings" {
  type = object({
    agent            = optional(number, 1)
    automatic_reboot = optional(bool, true)
    balloon          = optional(number, 0)
    bios             = optional(string, "seabios")
    cicustom         = optional(string, "")
    cipassword       = optional(string)
    ciuser           = string
    ciwait           = optional(number, 30)
    cores            = optional(number, 2)
    cpu              = optional(string, "host")
    description      = optional(string, "This Virtual Machine is hosts K8s Control Panel.")
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
    target_node      = string
    vm_name          = string
    vm_template      = string
    vm_id            = optional(number, 0)
  })
}

variable "control_node_disks" {
  description = "The disk(s) of the Control Node."
  type = list(object({
    storage            = string
    size               = string
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

variable "control_node_networks" {
  description = "The network adapters affiliated with the Control Node."
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

/*
variable "master_node_settings" {
  type = object({
    cores          = optional(number, 2),
    memory         = optional(number, 2048),
    disk_location  = optional(string),
    disk_type      = optional(string, "virtio"),
    disk_size      = optional(string, "10G"),
    network_bridge = optional(string),
    network_vlan   = optional(number, -1),
    vm_template    = string
  })
}*/

variable "master_node_count" {
  description = "Amount of master nodes in said cluster. Default is 1."
  type        = number
  default     = 0
}

variable "create_master_node" {
  description = "Determines if Master Node should be created or destroyed."
  type        = bool
  default     = false
}
