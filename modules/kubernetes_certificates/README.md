# kubernetes_certificates

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tls_cert_request.apiserver_ca_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.apiserver_client_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.apiserver_etcd_client_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.etcd_healthcheck_client_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.etcd_peer_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.etcd_server_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_cert_request.front_proxy_client_csr](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.apiserver_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.apiserver_etcd_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.apiserver_kubelet_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.etcd_healthcheck_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.etcd_peer_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.etcd_server_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_locally_signed_cert.front_proxy_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.apiserver_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.apiserver_etcd_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.apiserver_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.ca_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.etcd_ca_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.etcd_healthcheck_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.etcd_peer_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.etcd_server_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.front_proxy_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.front_proxy_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.sa_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/self_signed_cert) | resource |
| [tls_self_signed_cert.etcd_ca_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/self_signed_cert) | resource |
| [tls_self_signed_cert.front_proxy_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/self_signed_cert) | resource |
| [tls_certificate.apiserver_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.apiserver_etcd_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.apiserver_kubelet_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.ca_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.etcd_ca_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.etcd_healthcheck_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.etcd_peer_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.etcd_server_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.front_proxy_client_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_certificate.front_proxy_crt](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/certificate) | data source |
| [tls_public_key.apiserver_etcd_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.apiserver_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.apiserver_kubelet_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.ca_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.etcd_ca_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.etcd_healthcheck_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.etcd_peer_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.etcd_server_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.front_proxy_client_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.front_proxy_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |
| [tls_public_key.sa_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/data-sources/public_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_names"></a> [control\_plane\_names](#input\_control\_plane\_names) | [List(String)] The name of the Control Plane(s). This can be the Virtual Machine's name. | `list(string)` | n/a | yes |
| <a name="input_external_control_plane_ips"></a> [external\_control\_plane\_ips](#input\_external\_control\_plane\_ips) | [List(String)] The External IP Address(es) of the Control Plane(s). | `list(string)` | n/a | yes |
| <a name="input_internal_control_plane_ips"></a> [internal\_control\_plane\_ips](#input\_internal\_control\_plane\_ips) | [List(String)] The Internal IP Address(es) of the Control Plane(s). | `list(string)` | n/a | yes |
| <a name="input_virtual_ip"></a> [virtual\_ip](#input\_virtual\_ip) | The Virtual IP Address of the Load Balancer to handle API Server requests. Typically used with KeepaliveD/HAProxy. | `string` | n/a | yes |
| <a name="input_apiserver_client_name"></a> [apiserver\_client\_name](#input\_apiserver\_client\_name) | (String) The name of the Kubernetes API Server Client Certificate. Default is 'kube-apiserver-kubelet-client'. | `string` | `"kube-apiserver-kubelet-client"` | no |
| <a name="input_apiserver_name"></a> [apiserver\_name](#input\_apiserver\_name) | (String) The name of the Kubernetes API Server. Default is 'kube-apiserver'. | `string` | `"kube-apiserver"` | no |
| <a name="input_certificate_directory"></a> [certificate\_directory](#input\_certificate\_directory) | The default directory of the kubernetes certificates. Default is '/etc/kubernetes/pki' | `string` | `"/etc/kubernetes/pki"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | (String) The domain name of your cluster (e.g., mycompany.local). Default is 'cluster.local' | `string` | `"cluster.local"` | no |
| <a name="input_cluster_namespace"></a> [cluster\_namespace](#input\_cluster\_namespace) | (String) The cluster's namespace. Default is 'default' | `string` | `"default"` | no |
| <a name="input_create_certificates"></a> [create\_certificates](#input\_create\_certificates) | (Bool) Whether Terraform should generate the necessary certificates. Default is true. | `bool` | `true` | no |
| <a name="input_create_etcd_certificates"></a> [create\_etcd\_certificates](#input\_create\_etcd\_certificates) | "(Bool) Whether Terraform should generate the necessary certificates for etcd.<br>You would disable this functionality if you were to use a service other than etcd.<br><br>Default is true." | `bool` | `true` | no |
| <a name="input_early_renewal_hours"></a> [early\_renewal\_hours](#input\_early\_renewal\_hours) | (Number) The resource will consider the certificate to have expired the given number of hours before its actual expiry time.<br>This can be useful to deploy an updated certificate in advance of the expiration of the current certificate.<br>However, the old certificate remains valid until its true expiration time, since this resource does not (and cannot) support certificate revocation.<br><br>Default is 740. | `number` | `740` | no |
| <a name="input_etcd_apiserver_client_name"></a> [etcd\_apiserver\_client\_name](#input\_etcd\_apiserver\_client\_name) | (String) The Name of the certificate the apiserver uses to access etcd. Default is 'kube-apiserver-etcd-client'. | `string` | `"kube-apiserver-etcd-client"` | no |
| <a name="input_etcd_certificate_directory"></a> [etcd\_certificate\_directory](#input\_etcd\_certificate\_directory) | The default directory of the etcd server certificates. Default is '/etc/kubernetes/pki/etcd' | `string` | `"/etc/kubernetes/pki/etcd"` | no |
| <a name="input_etcd_healthcheck_name"></a> [etcd\_healthcheck\_name](#input\_etcd\_healthcheck\_name) | (String) The Name of the etcd healthcheck certificate. Default is 'kube-etcd-healthcheck-client'. | `string` | `"kube-etcd-healthcheck-client"` | no |
| <a name="input_etcd_name"></a> [etcd\_name](#input\_etcd\_name) | (String) The Name of the Kubernetes etcd Server. Default is 'etcd-ca'. | `string` | `"etcd-ca"` | no |
| <a name="input_front_proxy_client_name"></a> [front\_proxy\_client\_name](#input\_front\_proxy\_client\_name) | (String) The Name of the Kubernetes Front Proxy Client Certificate. Default is 'front-proxy-client'. | `string` | `"front-proxy-client"` | no |
| <a name="input_front_proxy_name"></a> [front\_proxy\_name](#input\_front\_proxy\_name) | (String) The Name of the Kubernetes Front Proxy CA Certificate. Default is 'front-proxy-ca'. | `string` | `"front-proxy-ca"` | no |
| <a name="input_validity_period_hours"></a> [validity\_period\_hours](#input\_validity\_period\_hours) | (Number) Number of hours, after initial issuing, that the certificate will remain valid for. Default is 87600. | `number` | `87600` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_certificates"></a> [all\_certificates](#output\_all\_certificates) | All certificate content and destination of this module. |
| <a name="output_all_certificates_destinations"></a> [all\_certificates\_destinations](#output\_all\_certificates\_destinations) | The destination location(s) of the certificates. |
| <a name="output_apiserver_crt"></a> [apiserver\_crt](#output\_apiserver\_crt) | The contents of apiserver.crt. |
| <a name="output_apiserver_etcd_client_crt"></a> [apiserver\_etcd\_client\_crt](#output\_apiserver\_etcd\_client\_crt) | The contents of apiserver-etcd-client.crt. |
| <a name="output_apiserver_etcd_client_key"></a> [apiserver\_etcd\_client\_key](#output\_apiserver\_etcd\_client\_key) | The contents of apiserver-etcd-client.key. |
| <a name="output_apiserver_etcd_client_pub"></a> [apiserver\_etcd\_client\_pub](#output\_apiserver\_etcd\_client\_pub) | The contents of apiserver-etcd-client.pub. |
| <a name="output_apiserver_key"></a> [apiserver\_key](#output\_apiserver\_key) | The contents of apiserver.key. |
| <a name="output_apiserver_kubelet_client_crt"></a> [apiserver\_kubelet\_client\_crt](#output\_apiserver\_kubelet\_client\_crt) | The contents of apiserver-kubelet-client.crt. |
| <a name="output_apiserver_kubelet_client_key"></a> [apiserver\_kubelet\_client\_key](#output\_apiserver\_kubelet\_client\_key) | The contents of apiserver-kubelet-client.key. |
| <a name="output_apiserver_kubelet_client_pub"></a> [apiserver\_kubelet\_client\_pub](#output\_apiserver\_kubelet\_client\_pub) | The contents of apiserver-kubelet-client.pub. |
| <a name="output_apiserver_pub"></a> [apiserver\_pub](#output\_apiserver\_pub) | The contents of apiserver.pub. |
| <a name="output_ca_crt"></a> [ca\_crt](#output\_ca\_crt) | The contents of ca.crt. |
| <a name="output_ca_key"></a> [ca\_key](#output\_ca\_key) | The contents of ca.key. |
| <a name="output_ca_pub"></a> [ca\_pub](#output\_ca\_pub) | The contents of ca.pub. |
| <a name="output_etcd_ca_crt"></a> [etcd\_ca\_crt](#output\_etcd\_ca\_crt) | The contents of etcd/ca.crt. |
| <a name="output_etcd_ca_key"></a> [etcd\_ca\_key](#output\_etcd\_ca\_key) | The contents of etcd/ca.key. |
| <a name="output_etcd_ca_pub"></a> [etcd\_ca\_pub](#output\_etcd\_ca\_pub) | The contents of etcd/ca.pub. |
| <a name="output_etcd_certificates"></a> [etcd\_certificates](#output\_etcd\_certificates) | The etcd certificates content and destination. |
| <a name="output_etcd_healthcheck_client_crt"></a> [etcd\_healthcheck\_client\_crt](#output\_etcd\_healthcheck\_client\_crt) | The contents of etcd/healthcheck-client.crt. |
| <a name="output_etcd_healthcheck_client_key"></a> [etcd\_healthcheck\_client\_key](#output\_etcd\_healthcheck\_client\_key) | The contents of etcd/healthcheck-client.key. |
| <a name="output_etcd_healthcheck_client_pub"></a> [etcd\_healthcheck\_client\_pub](#output\_etcd\_healthcheck\_client\_pub) | The contents of etcd/healthcheck-client.pub. |
| <a name="output_etcd_peer_crt"></a> [etcd\_peer\_crt](#output\_etcd\_peer\_crt) | The contents of etcd/peer.crt. |
| <a name="output_etcd_peer_key"></a> [etcd\_peer\_key](#output\_etcd\_peer\_key) | The contents of etcd/peer.key. |
| <a name="output_etcd_peer_pub"></a> [etcd\_peer\_pub](#output\_etcd\_peer\_pub) | The contents of etcd/peer.pub. |
| <a name="output_etcd_server_crt"></a> [etcd\_server\_crt](#output\_etcd\_server\_crt) | The contents of etcd/server.crt. |
| <a name="output_etcd_server_key"></a> [etcd\_server\_key](#output\_etcd\_server\_key) | The contents of etcd/server.key. |
| <a name="output_etcd_server_pub"></a> [etcd\_server\_pub](#output\_etcd\_server\_pub) | The contents of etcd/server.pub. |
| <a name="output_front_proxy_client_crt"></a> [front\_proxy\_client\_crt](#output\_front\_proxy\_client\_crt) | The contents of front-proxy-client.crt. |
| <a name="output_front_proxy_client_key"></a> [front\_proxy\_client\_key](#output\_front\_proxy\_client\_key) | The contents of front-proxy-client.key. |
| <a name="output_front_proxy_client_pub"></a> [front\_proxy\_client\_pub](#output\_front\_proxy\_client\_pub) | The contents of front-proxy-client.pub. |
| <a name="output_front_proxy_crt"></a> [front\_proxy\_crt](#output\_front\_proxy\_crt) | The contents of front-proxy.crt. |
| <a name="output_front_proxy_key"></a> [front\_proxy\_key](#output\_front\_proxy\_key) | The contents of front-proxy.key. |
| <a name="output_front_proxy_pub"></a> [front\_proxy\_pub](#output\_front\_proxy\_pub) | The contents of front-proxy.pub. |
| <a name="output_primary_certificates"></a> [primary\_certificates](#output\_primary\_certificates) | The contents and destinations of the primary certificates. |
| <a name="output_sa_key"></a> [sa\_key](#output\_sa\_key) | The contents of sa.key. |
| <a name="output_sa_pub"></a> [sa\_pub](#output\_sa\_pub) | The contents of sa.pub. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
