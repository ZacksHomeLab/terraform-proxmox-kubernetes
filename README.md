# terraform-proxmox-k3s

Deploying a Kubernetes cluster can be overwhelming. Documentation I found online skips through the setup process and just shows the finished product. This module does that as well, to a degree...BUT, you can add the necessary features granularly. This README will walk you through deploying different variations of Kubernetes clusters. If you know what you're doing, you may use the ***examples*** directory.

# Getting Started

This module utilizes my [Proxmox Cloudinit Module](https://github.com/ZacksHomeLab/terraform-proxmox-cloudinit-vm), which gives a lot of customization out-of-the-box for Virtual Machines.

This module assumes you've followed the [Getting Started](https://github.com/ZacksHomeLab/terraform-proxmox-cloudinit-vm#getting-started) section of the above-mentioned module. You will need an **Ubuntu (preferably 22.04.x) Cloudinit Virtual Machine template** to use this module. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.3.0 |
| <a name="requirement_macaddress"></a> [macaddress](#requirement\_macaddress) | 0.3.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 2.9.14 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clone"></a> [clone](#input\_clone) | The base VM from which to clone to create the new VM. Note that clone is mutually exclussive with pxe and iso modes. | `string` | n/a | yes |
| <a name="input_disks"></a> [disks](#input\_disks) | The disk(s) of the Virtual Machine. | <pre>list(object({<br>    storage            = string<br>    size               = string<br>    type               = optional(string, "virtio")<br>    format             = optional(string, "raw")<br>    cache              = optional(string, "none")<br>    backup             = optional(bool, false)<br>    iothread           = optional(number, 0)<br>    discard            = optional(number, 0)<br>    replicate          = optional(number, 0)<br>    ssd                = optional(number, 0)<br>    mbps               = optional(number, 0)<br>    mbps_rd            = optional(number, 0)<br>    mbps_rd_max        = optional(number, 0)<br>    mbps_wr            = optional(number, 0)<br>    mbps_wr_max        = optional(number, 0)<br>    iops               = optional(number, 0)<br>    iops_rd            = optional(number, 0)<br>    iops_rd_max        = optional(number, 0)<br>    iops_rd_max_length = optional(number, 0)<br>    iops_wr            = optional(number, 0)<br>    iops_wr_max        = optional(number, 0)<br>    iops_wr_max_length = optional(number, 0)<br>  }))</pre> | n/a | yes |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | The name of the Proxmox Node on which to place the VM. | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The virtual machine name. | `string` | n/a | yes |
| <a name="input_automatic_reboot"></a> [automatic\_reboot](#input\_automatic\_reboot) | Automatically reboot the VM when parameter changes require this. If disabled the provider will emit a warning when the VM needs to be rebooted. | `bool` | `true` | no |
| <a name="input_balloon"></a> [balloon](#input\_balloon) | The minimum amount of memory to allocate to the VM in Megabytes, when Automatic Memory Allocation is desired. Proxmox will enable a balloon device on the guest to manage dynamic allocation. See the docs about memory for more info. | `number` | `0` | no |
| <a name="input_boot"></a> [boot](#input\_boot) | The boot order for the VM. For example: order=scsi0;ide2;net0. | `string` | `""` | no |
| <a name="input_bootdisk"></a> [bootdisk](#input\_bootdisk) | Enable booting from specified disk. You shouldn't need to change it under most circumstances. | `string` | `""` | no |
| <a name="input_ci_wait"></a> [ci\_wait](#input\_ci\_wait) | How to long in seconds to wait for before provisioning. | `number` | `30` | no |
| <a name="input_cicustom"></a> [cicustom](#input\_cicustom) | Instead specifying ciuser, cipasword, etc… you can specify the path to a custom cloud-init config file here. Grants more flexibility in configuring cloud-init. | `string` | `""` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Override the default cloud-init user's password. Sensitive. | `string` | `""` | no |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Override the default cloud-init user for provisioning. | `string` | `""` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | The number of CPU cores per CPU socket to allocate to the VM. | `number` | `2` | no |
| <a name="input_create_vm"></a> [create\_vm](#input\_create\_vm) | Controls if virtual machine should be created. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the VM. Shows as the 'Notes' field in the Proxmox GUI. | `string` | `""` | no |
| <a name="input_force_create"></a> [force\_create](#input\_force\_create) | If false, and a vm of the same name, on the same node exists, terraform will attempt to reconfigure that VM with these settings. Set to true to always create a new VM (note, the name of the VM must still be unique, otherwise an error will be produced.). | `bool` | `false` | no |
| <a name="input_force_recreate_on_change_of"></a> [force\_recreate\_on\_change\_of](#input\_force\_recreate\_on\_change\_of) | If the value of this string changes, the VM will be recreated. Useful for allowing this resource to be recreated when arbitrary attributes change. An example where this is useful is a cloudinit configuration (as the cicustom attribute points to a file not the content). | `string` | `""` | no |
| <a name="input_hagroup"></a> [hagroup](#input\_hagroup) | The HA group identifier the resource belongs to (requires hastate to be set!). | `string` | `""` | no |
| <a name="input_hastate"></a> [hastate](#input\_hastate) | Requested HA state for the resource. One of 'started', 'stopped', 'enabled', 'disabled', or 'ignored'. See the docs about HA for more info. | `string` | `""` | no |
| <a name="input_hotplug"></a> [hotplug](#input\_hotplug) | Comma delimited list of hotplug features to enable. Options: network, disk, cpu, memory, usb. Set to 0 to disable hotplug. | `string` | `"cpu,network,disk,usb"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to allocate to the VM in Megabytes. | `number` | `4096` | no |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | Sets default DNS server for guest. | `string` | `""` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | The network adapters affiliated with the Virtual Machine. | <pre>list(object({<br>    bridge    = optional(string, "vmbr0")<br>    model     = optional(string, "virtio")<br>    gateway   = optional(string)<br>    gateway6  = optional(string)<br>    ip        = optional(string)<br>    ip6       = optional(string)<br>    dhcp      = optional(bool, false)<br>    dhcp6     = optional(bool, false)<br>    firewall  = optional(bool, false)<br>    link_down = optional(bool, false)<br>    macaddr   = optional(string)<br>    queues    = optional(number, 1)<br>    rate      = optional(number, 0)<br>    vlan_tag  = optional(number, -1)<br>  }))</pre> | `[]` | no |
| <a name="input_numa"></a> [numa](#input\_numa) | Whether to enable Non-Uniform Memory Access in the guest. | `bool` | `false` | no |
| <a name="input_onboot"></a> [onboot](#input\_onboot) | Whether to have the VM startup after the PVE node starts. | `bool` | `false` | no |
| <a name="input_oncreate"></a> [oncreate](#input\_oncreate) | Whether to have the VM startup after the VM is created. | `bool` | `true` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | The resource pool to which the VM will be added. | `string` | `""` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | The SCSI controller to emulate. Options: lsi, lsi53c810, megasas, pvscsi, virtio-scsi-pci, virtio-scsi-single. | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | Sets default DNS search domain suffix. | `string` | `""` | no |
| <a name="input_sockets"></a> [sockets](#input\_sockets) | The number of CPU sockets for the Master Node. | `number` | `1` | no |
| <a name="input_sshkeys"></a> [sshkeys](#input\_sshkeys) | Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of the VM. This is only meta information. | `list(string)` | `[]` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | The ID of the VM in Proxmox. The default value of 0 indicates it should use the next available ID in the sequence. | `number` | `0` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
