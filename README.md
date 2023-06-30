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
| <a name="module_control_planes"></a> [control\_planes](#module\_control\_planes) | ZacksHomeLab/cloudinit-vm/proxmox | 1.7.1 |
| <a name="module_ext_apiserver_lb"></a> [ext\_apiserver\_lb](#module\_ext\_apiserver\_lb) | ZacksHomeLab/cloudinit-vm/proxmox | 1.7.1 |
| <a name="module_workers"></a> [workers](#module\_workers) | ZacksHomeLab/cloudinit-vm/proxmox | 1.7.1 |

## Resources

| Name | Type |
|------|------|
| [local_file.init_kubeadm_script](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [local_file.prepare_control_node_script](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [local_file.prepare_ext_apiserver_lb](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [null_resource.init_kubeadm](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [null_resource.join_kubeadm](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [null_resource.prepare_control_planes](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [null_resource.setup_ext_apiserver_lb](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [random_password.ext_apiserver_keepalive_pass](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/password) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apiserver_dest_port"></a> [apiserver\_dest\_port](#input\_apiserver\_dest\_port) | (String) The default destination port the apiserver will liste on. Default is 8443. | `number` | `6443` | no |
| <a name="input_apiserver_lb_virtual_ip"></a> [apiserver\_lb\_virtual\_ip](#input\_apiserver\_lb\_virtual\_ip) | (String) The Virtual IP address (in CIDR-Notation) the load balancer will listen on. Note: This must be a routable IP that the Control Plane can access. Default is 192.168.2.100/24 | `string` | `"192.168.2.120/24"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | The domain of your cluster (e.g., mycompany.local). Default is 'cluster.local' | `string` | `"cluster.local"` | no |
| <a name="input_cluster_namespace"></a> [cluster\_namespace](#input\_cluster\_namespace) | (String) The cluster's namespace. Default is 'default' | `string` | `"default"` | no |
| <a name="input_create_certificates"></a> [create\_certificates](#input\_create\_certificates) | (Bool) Whether Terraform should generate the necessary certificates. Default is true. | `bool` | `true` | no |
| <a name="input_create_control_plane"></a> [create\_control\_plane](#input\_create\_control\_plane) | (Bool) Determines if Control Node should be created or destroyed. | `bool` | `true` | no |
| <a name="input_create_etcd_certificates"></a> [create\_etcd\_certificates](#input\_create\_etcd\_certificates) | "(Bool) Whether Terraform should generate the necessary certificates for etcd.<br>You would disable this functionality if you were to use a service other than etcd.<br><br>Default is true." | `bool` | `true` | no |
| <a name="input_create_ext_apiserver_lb"></a> [create\_ext\_apiserver\_lb](#input\_create\_ext\_apiserver\_lb) | (Bool) Determines if an External API Server Load Balancer should be created or destroyed. | `bool` | `false` | no |
| <a name="input_create_worker"></a> [create\_worker](#input\_create\_worker) | (Bool) Determines if Worker Node(s) should be created or destroyed. | `bool` | `true` | no |
| <a name="input_etcd_dest_port"></a> [etcd\_dest\_port](#input\_etcd\_dest\_port) | (Number) The destination port for etcd. Default is 2380. | `number` | `2380` | no |
| <a name="input_etcd_src_port"></a> [etcd\_src\_port](#input\_etcd\_src\_port) | (Number) The source port for etcd. Default is 2379. | `number` | `2379` | no |
| <a name="input_ext_apiserver_lb_port"></a> [ext\_apiserver\_lb\_port](#input\_ext\_apiserver\_lb\_port) | (String) The default port the External Apiserver LB will listen on. Default is 8443. | `number` | `6443` | no |
| <a name="input_keepalive_router_id"></a> [keepalive\_router\_id](#input\_keepalive\_router\_id) | (Number) The Router ID for Keepalive. You would change this number if you have multiple clusters using this module and Keepalive. Default is 51. | `number` | `51` | no |
| <a name="input_pod_network"></a> [pod\_network](#input\_pod\_network) | (String) Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node. Default value is 10.244.0.0/16 | `string` | `"10.244.0.0/16"` | no |
| <a name="input_pods_on_control_plane"></a> [pods\_on\_control\_plane](#input\_pods\_on\_control\_plane) | (Bool) Defines the ability to deploy Pods on the Control Plane node. Typically done in small clusters. Default is false. | `bool` | `true` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The private key file to connect to said Virtual Machine. | `string` | `null` | no |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | (String) Use alternative range of IP address for service VIPs. Default value is 10.96.0.0/12 | `string` | `"10.96.0.0/12"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_planes_ip"></a> [control\_planes\_ip](#output\_control\_planes\_ip) | The primary IP addresses of each Control Plane Virtual Machine. |
| <a name="output_control_planes_ssh"></a> [control\_planes\_ssh](#output\_control\_planes\_ssh) | The ssh settings of each Control Plane Virtual Machine. |
| <a name="output_control_planes_vm_name"></a> [control\_planes\_vm\_name](#output\_control\_planes\_vm\_name) | The Virtual Machine Name of each Control Plane. |
| <a name="output_ext_apiserver_lb_ip"></a> [ext\_apiserver\_lb\_ip](#output\_ext\_apiserver\_lb\_ip) | The primary IP addresses of each External API Server Virtual Machine. |
| <a name="output_ext_apiserver_lb_ssh"></a> [ext\_apiserver\_lb\_ssh](#output\_ext\_apiserver\_lb\_ssh) | The ssh settings of each External API Server Virtual Machine. |
| <a name="output_ext_apiserver_lb_vm_name"></a> [ext\_apiserver\_lb\_vm\_name](#output\_ext\_apiserver\_lb\_vm\_name) | The Virtual Machine Name of each External API Server. |
| <a name="output_kube_token"></a> [kube\_token](#output\_kube\_token) | The kubenetes token used for joining node(s) to said cluster. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
