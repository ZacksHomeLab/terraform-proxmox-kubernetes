variable "control_plane" {
  description = "This variables holds all Control Plane specific configuration(s)."
  type        = map(any)
  default     = null
}

variable "worker" {
  description = "This variables holds all Worker specific configuration(s)."
  type        = map(any)
  default     = null
}

variable "target_node" {
  description = "The default target node for all Virtual Machines."
  type        = string
}

variable "template" {
  description = "The default name of the Virtual Machine template to clone the Virtual Machine from."
  type        = string
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
  description = "The network adapters affiliated with the Control Plane node."
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
