variable "automatic_reboot" {
  description = "Automatically reboot the VM when parameter changes require this. If disabled the provider will emit a warning when the VM needs to be rebooted."
  type        = bool
  default     = true
}

variable "balloon" {
  description = "The minimum amount of memory to allocate to the VM in Megabytes, when Automatic Memory Allocation is desired. Proxmox will enable a balloon device on the guest to manage dynamic allocation. See the docs about memory for more info."
  type        = number
  default     = 0
}

variable "boot" {
  description = "The boot order for the VM. For example: order=scsi0;ide2;net0."
  type        = string
  default     = ""
}

variable "bootdisk" {
  description = "Enable booting from specified disk. You shouldn't need to change it under most circumstances."
  type        = string
  default     = ""
}

variable "ci_wait" {
  description = "How to long in seconds to wait for before provisioning."
  type        = number
  default     = 30
}

variable "cicustom" {
  description = "Instead specifying ciuser, cipasword, etc… you can specify the path to a custom cloud-init config file here. Grants more flexibility in configuring cloud-init."
  type        = string
  default     = ""
}

variable "cipassword" {
  description = "Override the default cloud-init user's password. Sensitive."
  type        = string
  sensitive   = true
  default     = ""
}

variable "ciuser" {
  description = "Override the default cloud-init user for provisioning."
  type        = string
  default     = ""
}

variable "clone" {
  description = "The base VM from which to clone to create the new VM. Note that clone is mutually exclussive with pxe and iso modes."
  type        = string
}

variable "cores" {
  description = "The number of CPU cores per CPU socket to allocate to the VM."
  type        = number
  default     = 2
}

variable "create_vm" {
  description = "Controls if virtual machine should be created."
  type        = bool
  default     = true
}

variable "description" {
  description = "The description of the VM. Shows as the 'Notes' field in the Proxmox GUI."
  type        = string
  default     = ""
}

variable "disks" {
  description = "The disk(s) of the Virtual Machine."
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

variable "force_create" {
  description = "If false, and a vm of the same name, on the same node exists, terraform will attempt to reconfigure that VM with these settings. Set to true to always create a new VM (note, the name of the VM must still be unique, otherwise an error will be produced.)."
  type        = bool
  default     = false
}

variable "force_recreate_on_change_of" {
  description = "If the value of this string changes, the VM will be recreated. Useful for allowing this resource to be recreated when arbitrary attributes change. An example where this is useful is a cloudinit configuration (as the cicustom attribute points to a file not the content)."
  type        = string
  default     = ""
}

variable "hagroup" {
  description = "The HA group identifier the resource belongs to (requires hastate to be set!)."
  type        = string
  default     = ""
}

variable "hastate" {
  description = "Requested HA state for the resource. One of 'started', 'stopped', 'enabled', 'disabled', or 'ignored'. See the docs about HA for more info."
  type        = string
  default     = ""
}

variable "hotplug" {
  description = "Comma delimited list of hotplug features to enable. Options: network, disk, cpu, memory, usb. Set to 0 to disable hotplug."
  type        = string
  default     = "cpu,network,disk,usb"
}

variable "memory" {
  description = "The amount of memory to allocate to the VM in Megabytes."
  type        = number
  default     = 4096
}

variable "nameserver" {
  description = "Sets default DNS server for guest."
  type        = string
  default     = ""
}

variable "networks" {
  description = "The network adapters affiliated with the Virtual Machine."
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

variable "numa" {
  description = "Whether to enable Non-Uniform Memory Access in the guest."
  type        = bool
  default     = false
}

variable "onboot" {
  description = "Whether to have the VM startup after the PVE node starts."
  type        = bool
  default     = false
}

variable "oncreate" {
  description = "Whether to have the VM startup after the VM is created."
  type        = bool
  default     = true
}

variable "pool" {
  description = "The resource pool to which the VM will be added."
  type        = string
  default     = ""
}

variable "scsihw" {
  description = "The SCSI controller to emulate. Options: lsi, lsi53c810, megasas, pvscsi, virtio-scsi-pci, virtio-scsi-single."
  type        = string
  default     = "virtio-scsi-pci"
}

variable "searchdomain" {
  description = "Sets default DNS search domain suffix."
  type        = string
  default     = ""
}

variable "sockets" {
  description = "The number of CPU sockets for the Master Node."
  type        = number
  default     = 1
}

variable "sshkeys" {
  description = "Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags of the VM. This is only meta information."
  type        = list(string)
  default     = []
}

variable "target_node" {
  description = "The name of the Proxmox Node on which to place the VM."
  type        = string
}

variable "vm_name" {
  description = "The virtual machine name."
  type        = string
}

variable "vmid" {
  description = "The ID of the VM in Proxmox. The default value of 0 indicates it should use the next available ID in the sequence."
  type        = number
  default     = 0
}
