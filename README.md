# terraform-proxmox-kubernetes

WIP

# Getting Started

This module utilizes my [Proxmox Cloudinit Module](https://github.com/ZacksHomeLab/terraform-proxmox-cloudinit-vm), which gives a lot of customization out-of-the-box for Virtual Machines.

This module assumes you've followed the [Getting Started](https://github.com/ZacksHomeLab/terraform-proxmox-cloudinit-vm#getting-started) section of the above-mentioned module. You will need an **Ubuntu (preferably 22.04.x) Cloudinit Virtual Machine template** to use this module. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4.0 |
| <a name="requirement_macaddress"></a> [macaddress](#requirement\_macaddress) | 0.3.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 2.9.14 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certs"></a> [certs](#module\_certs) | ./modules/kubernetes_certificates | n/a |
| <a name="module_control_planes"></a> [control\_planes](#module\_control\_planes) | ZacksHomeLab/cloudinit-vm/proxmox | 1.7.0 |
| <a name="module_workers"></a> [workers](#module\_workers) | ZacksHomeLab/cloudinit-vm/proxmox | 1.7.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.prepare_control_node_script](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [null_resource.setup_control_node](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | (String) The default target node for all Virtual Machines. | `string` | n/a | yes |
| <a name="input_template"></a> [template](#input\_template) | (String) The default name of the Virtual Machine template to clone the Virtual Machine from. | `string` | n/a | yes |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | The domain of your cluster (e.g., mycompany.local). Default is 'cluster.local' | `string` | `"cluster.local"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (String) The name of your Kubernetes Cluster. Default is 'kubernetes'. | `string` | `"kubernetes"` | no |
| <a name="input_cluster_namespace"></a> [cluster\_namespace](#input\_cluster\_namespace) | (String) The cluster's namespace. Default is 'default' | `string` | `"default"` | no |
| <a name="input_control_plane_count"></a> [control\_plane\_count](#input\_control\_plane\_count) | (Number) The amount of Control Plane(s) Virtual Machine(s) to be created. | `number` | `1` | no |
| <a name="input_control_plane_disks"></a> [control\_plane\_disks](#input\_control\_plane\_disks) | [List{Object}] The disk(s) settings for Control Plane Virtual Machine(s). | <pre>list(object({<br>    storage            = optional(string)<br>    size               = optional(string)<br>    type               = optional(string)<br>    format             = optional(string)<br>    cache              = optional(string)<br>    backup             = optional(bool)<br>    iothread           = optional(number)<br>    discard            = optional(number)<br>    replicate          = optional(number)<br>    ssd                = optional(number)<br>    mbps               = optional(number)<br>    mbps_rd            = optional(number)<br>    mbps_rd_max        = optional(number)<br>    mbps_wr            = optional(number)<br>    mbps_wr_max        = optional(number)<br>    iops               = optional(number)<br>    iops_rd            = optional(number)<br>    iops_rd_max        = optional(number)<br>    iops_rd_max_length = optional(number)<br>    iops_wr            = optional(number)<br>    iops_wr_max        = optional(number)<br>    iops_wr_max_length = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_control_plane_networks"></a> [control\_plane\_networks](#input\_control\_plane\_networks) | [List{Object}] The network adapter(s) affiliated with Control Plane Node(s). | <pre>list(object({<br>    bridge    = optional(string)<br>    model     = optional(string)<br>    gateway   = optional(string)<br>    gateway6  = optional(string)<br>    ip        = optional(string)<br>    ip6       = optional(string)<br>    dhcp      = optional(bool)<br>    dhcp6     = optional(bool)<br>    firewall  = optional(bool)<br>    link_down = optional(bool)<br>    macaddr   = optional(string)<br>    queues    = optional(number)<br>    rate      = optional(number)<br>    vlan_tag  = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_control_plane_settings"></a> [control\_plane\_settings](#input\_control\_plane\_settings) | {Object} The settings for Control Plane Node(s). | <pre>object({<br>    automatic_reboot = optional(bool)<br>    balloon          = optional(number)<br>    bios             = optional(string)<br>    cicustom         = optional(string)<br>    cipassword       = optional(string)<br>    ciuser           = optional(string)<br>    ciwait           = optional(number)<br>    cores            = optional(number)<br>    cpu              = optional(string)<br>    description      = optional(string, "This Virtual Machine hosts K8's Control Pane.")<br>    hotplug          = optional(string)<br>    memory           = optional(number)<br>    nameserver       = optional(string)<br>    onboot           = optional(bool)<br>    oncreate         = optional(bool)<br>    pool             = optional(string)<br>    scsihw           = optional(string)<br>    searchdomain     = optional(string)<br>    sshkeys          = optional(string)<br>    sockets          = optional(number)<br>    tags             = optional(list(string))<br>    target_node      = optional(string)<br>    template         = optional(string)<br>    vm_name          = optional(string, "k8-plane")<br>    vm_id            = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_create_certificates"></a> [create\_certificates](#input\_create\_certificates) | (Bool) Whether Terraform should generate the necessary certificates. Default is true. | `bool` | `true` | no |
| <a name="input_create_control_plane"></a> [create\_control\_plane](#input\_create\_control\_plane) | (Bool) Determines if Control Node should be created or destroyed. | `bool` | `true` | no |
| <a name="input_create_etcd_certificates"></a> [create\_etcd\_certificates](#input\_create\_etcd\_certificates) | "(Bool) Whether Terraform should generate the necessary certificates for etcd.<br>You would disable this functionality if you were to use a service other than etcd.<br><br>Default is true." | `bool` | `true` | no |
| <a name="input_create_worker"></a> [create\_worker](#input\_create\_worker) | (Bool) Determines if Worker Node(s) should be created or destroyed. | `bool` | `true` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | [List{Object}] The default disk(s) for all Virtual Machines. | <pre>list(object({<br>    storage            = optional(string)<br>    size               = optional(string, "10G")<br>    type               = optional(string, "virtio")<br>    format             = optional(string, "raw")<br>    cache              = optional(string, "none")<br>    backup             = optional(bool, false)<br>    iothread           = optional(number, 0)<br>    discard            = optional(number, 0)<br>    replicate          = optional(number, 0)<br>    ssd                = optional(number, 0)<br>    mbps               = optional(number, 0)<br>    mbps_rd            = optional(number, 0)<br>    mbps_rd_max        = optional(number, 0)<br>    mbps_wr            = optional(number, 0)<br>    mbps_wr_max        = optional(number, 0)<br>    iops               = optional(number, 0)<br>    iops_rd            = optional(number, 0)<br>    iops_rd_max        = optional(number, 0)<br>    iops_rd_max_length = optional(number, 0)<br>    iops_wr            = optional(number, 0)<br>    iops_wr_max        = optional(number, 0)<br>    iops_wr_max_length = optional(number, 0)<br>  }))</pre> | `[]` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | [List{Object}] The network adapter(s) affiliated with the Control Plane Virtual Machine(s). | <pre>list(object({<br>    bridge    = optional(string, "vmbr0")<br>    model     = optional(string, "virtio")<br>    gateway   = optional(string)<br>    gateway6  = optional(string)<br>    ip        = optional(string)<br>    ip6       = optional(string)<br>    dhcp      = optional(bool, false)<br>    dhcp6     = optional(bool, false)<br>    firewall  = optional(bool, false)<br>    link_down = optional(bool, false)<br>    macaddr   = optional(string)<br>    queues    = optional(number, 1)<br>    rate      = optional(number, 0)<br>    vlan_tag  = optional(number, -1)<br>  }))</pre> | `[]` | no |
| <a name="input_pod_network"></a> [pod\_network](#input\_pod\_network) | (String) Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node. Default value is 172.16.0.0/16 | `string` | `"172.16.0.0/16"` | no |
| <a name="input_pods_on_control_plane"></a> [pods\_on\_control\_plane](#input\_pods\_on\_control\_plane) | (Bool) Defines the ability to deploy Pods on the Control Plane node. Typically done in small clusters. Default is false. | `bool` | `true` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The private key file to connect to said Virtual Machine. | `string` | `null` | no |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | (String) Use alternative range of IP address for service VIPs. Default value is 10.96.0.0/12 | `string` | `"10.96.0.0/12"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | {Object} The default settings for Virtual Machine(s). | <pre>object({<br>    automatic_reboot = optional(bool, true)<br>    balloon          = optional(number, 0)<br>    bios             = optional(string, "seabios")<br>    cicustom         = optional(string)<br>    cipassword       = optional(string)<br>    ciuser           = optional(string)<br>    ciwait           = optional(number, 30)<br>    cores            = optional(number, 1)<br>    cpu              = optional(string, "host")<br>    description      = optional(string, "This is a Virtual Machine.")<br>    hotplug          = optional(string, "cpu,network,disk,usb")<br>    memory           = optional(number, 2048)<br>    nameserver       = optional(string)<br>    onboot           = optional(bool)<br>    oncreate         = optional(bool)<br>    pool             = optional(string)<br>    scsihw           = optional(string, "virtio-scsi-pci")<br>    searchdomain     = optional(string)<br>    sshkeys          = optional(string)<br>    sockets          = optional(number, 1)<br>    tags             = optional(list(string))<br>    vm_id            = optional(number, 0)<br>  })</pre> | `{}` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | (Number) The amount of Worker Node(s) Virtual Machine(s) to be created. | `number` | `0` | no |
| <a name="input_worker_disks"></a> [worker\_disks](#input\_worker\_disks) | [List{Object}] The disk(s) of the Worker Node(s). | <pre>list(object({<br>    storage            = optional(string)<br>    size               = optional(string)<br>    type               = optional(string)<br>    format             = optional(string)<br>    cache              = optional(string)<br>    backup             = optional(bool)<br>    iothread           = optional(number)<br>    discard            = optional(number)<br>    replicate          = optional(number)<br>    ssd                = optional(number)<br>    mbps               = optional(number)<br>    mbps_rd            = optional(number)<br>    mbps_rd_max        = optional(number)<br>    mbps_wr            = optional(number)<br>    mbps_wr_max        = optional(number)<br>    iops               = optional(number)<br>    iops_rd            = optional(number)<br>    iops_rd_max        = optional(number)<br>    iops_rd_max_length = optional(number)<br>    iops_wr            = optional(number)<br>    iops_wr_max        = optional(number)<br>    iops_wr_max_length = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_worker_networks"></a> [worker\_networks](#input\_worker\_networks) | [List{Object}] The network adapters affiliated with the Worker Node(s). | <pre>list(object({<br>    bridge    = optional(string)<br>    model     = optional(string)<br>    gateway   = optional(string)<br>    gateway6  = optional(string)<br>    ip        = optional(string)<br>    ip6       = optional(string)<br>    dhcp      = optional(bool)<br>    dhcp6     = optional(bool)<br>    firewall  = optional(bool)<br>    link_down = optional(bool)<br>    macaddr   = optional(string)<br>    queues    = optional(number)<br>    rate      = optional(number)<br>    vlan_tag  = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_worker_settings"></a> [worker\_settings](#input\_worker\_settings) | {Object} The settings for Worker Node(s). | <pre>object({<br>    automatic_reboot = optional(bool)<br>    balloon          = optional(number)<br>    bios             = optional(string)<br>    cicustom         = optional(string)<br>    cipassword       = optional(string)<br>    ciuser           = optional(string)<br>    ciwait           = optional(number)<br>    cores            = optional(number)<br>    cpu              = optional(string)<br>    description      = optional(string, "This Virtual Machine is a K8 Worker Node.")<br>    hotplug          = optional(string)<br>    memory           = optional(number)<br>    nameserver       = optional(string)<br>    onboot           = optional(bool)<br>    oncreate         = optional(bool)<br>    pool             = optional(string)<br>    scsihw           = optional(string)<br>    searchdomain     = optional(string)<br>    sshkeys          = optional(string)<br>    sockets          = optional(number)<br>    tags             = optional(list(string))<br>    target_node      = optional(string)<br>    template         = optional(string)<br>    vm_name          = optional(string, "k8-worker")<br>    vm_id            = optional(number)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_planes_ip"></a> [control\_planes\_ip](#output\_control\_planes\_ip) | The primary IP addresses of each Virtual Machine. |
| <a name="output_control_planes_ssh"></a> [control\_planes\_ssh](#output\_control\_planes\_ssh) | The ssh settings of each Virtual Machine. |
| <a name="output_kube_token"></a> [kube\_token](#output\_kube\_token) | The kubenetes token used for joining node(s) to said cluster. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
