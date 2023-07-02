/*
  DO NOT MODIFY ANYTHING IN LOCALS!!!
*/
locals {
  # Determine whether to initialize the certs module or not
  create_certificates = var.create_certificates || var.create_etcd_certificates ? 1 : 0
}

module "certs" {
  count  = local.create_certificates
  source = "./modules/kubernetes_certificates"

  create_certificates      = var.create_certificates
  create_etcd_certificates = var.create_etcd_certificates

  cluster_domain    = var.cluster_domain
  cluster_namespace = var.cluster_namespace

  control_plane_names = module.control_planes[*].name

  /*
    Internal Control Plane IP Addresses
      This variable will iterate through the number of Control Plane Virtual Machines
        and create an IP Address based off of the Service Network Subnet (e.g., 10.96.0.0/12).

      For example, if the user is creating 3 control planes and using the default Service Network,
        the following IP Addresses will be created:
          * 10.96.0.1
          * 10.96.0.2
          * 10.96.0.3
  */
  internal_control_plane_ips = try([for i, vm in module.control_planes : cidrhost(var.service_network, (i + 1))], cidrhost(var.service_network, 1))
  external_control_plane_ips = module.control_planes[*].ip
  virtual_ip                 = local.apiserver_lb_virtual_ip

  /*
    Some certificates require the IP Address of a Control Plane and it may not be found until AFTER it's fully provisioned.

    For example, if the user decides to use DHCP for their Control Planes. Removing this will cause some certificates to
      fail when they are being creating in setup_control_plane.tf
  */
  depends_on = [module.control_planes]
}
