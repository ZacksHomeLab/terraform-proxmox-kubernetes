locals {

  prepare_apiserver_script_template = "${path.module}/templates/prepare_apiserver_lb.sh.tftpl"
  prepare_apiserver_script_rendered = "${path.module}/rendered/prepare_apiserver_lb.sh"
  prepare_apiserver_script_dest     = "/tmp/${basename(local.prepare_apiserver_script_rendered)}"

  create_apiserver_lb = local.control_plane_count > 0 && var.create_apiserver_lb ? 1 : 0
}

resource "random_password" "apiserver_keepalived_pass" {
  count = local.create_apiserver_lb
  # Keepalived truncates the password to 8 characters
  length  = 8
  special = false

  # By default, random providers generate new values ONLY if they're deleted. So,
  #   it may not be necessary to have a 'keeper' or 'trigger'
  /*keepers = {
    vm_id = module.control_planes[0].vmid
  }*/
}

resource "local_file" "prepare_apiserver_lb" {
  count = local.create_apiserver_lb

  content = templatefile(local.prepare_apiserver_script_template, {
    apiserver_dest_port = var.apiserver_dest_port
    lb_port             = var.apiserver_lb_port
    keepalive_router_id = var.keepalive_router_id
    keepalive_pass      = random_password.apiserver_keepalived_pass[0].result
    virtual_ip          = local.apiserver_lb_virtual_ip
    vms                 = module.control_planes
  })

  filename = local.prepare_apiserver_script_rendered
}

/*
  Unfortunately, Proxmox is not stable enough to support the creation of
    multiple Load Balancers at the same time.

  THe hack around this is to have one resource for the first LB
    (aka, the 'master') and the remaining Control Planes to
    run on null_resource 'setup_additional_apiserver_lbs'.

  This should speed up provisioning, drastically.
*/
resource "null_resource" "setup_primary_apiserver_lb" {
  count = local.control_plane_count > 0 ? 1 : 0

  connection {
    host        = module.control_planes[0].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.control_planes[0].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.prepare_apiserver_lb[0].filename
    destination = local.prepare_apiserver_script_dest
  }

  /*
    prepare_apiserver_lb.sh accepts 3 parameters
      1. The Current API Server LB's IP Address
      2. The KeepaliveD password
      3. Set the state to 'MASTER' if this is the first Load Balancer, otherwise
          set the remaining LB(s) to 'BACKUP'.
  */
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x ${local.prepare_apiserver_script_dest} && \
        sudo ${local.prepare_apiserver_script_dest} \
        ${module.control_planes[0].ip} \
        ${random_password.apiserver_keepalived_pass[0].result} MASTER
      EOT
      ,
      ##sudo rm ${local.prepare_apiserver_script_dest}
    ]
  }

  triggers = {
    vmid = module.control_planes[0].vmid
  }

  # Prevent this resource from running until external_lb(s) are fully provisioned
  depends_on = [null_resource.prepare_control_planes]
}

/*
  See comments above setup_primary_apiserver_lb
*/
resource "null_resource" "setup_additional_apiserver_lbs" {
  count = local.control_plane_count > 1 ? local.control_plane_count - 1 : 0

  connection {
    host        = module.control_planes[count.index + 1].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.control_planes[count.index + 1].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.prepare_apiserver_lb[0].filename
    destination = local.prepare_apiserver_script_dest
  }

  /*
    prepare_apiserver_lb.sh accepts 3 parameters
      1. The Current API Server LB's IP Address
      2. The KeepaliveD password
      3. Set the state to 'MASTER' if this is the first Load Balancer, otherwise
          set the remaining LB(s) to 'BACKUP'.
  */
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x ${local.prepare_apiserver_script_dest} && \
        sudo ${local.prepare_apiserver_script_dest} \
        ${module.control_planes[count.index + 1].ip} \
        ${random_password.apiserver_keepalived_pass[0].result} BACKUP
      EOT
      ,
      ##sudo rm ${local.prepare_apiserver_script_dest}
    ]
  }

  triggers = {
    vmid = module.control_planes[count.index + 1].vmid
  }

  # Prevent this resource from running until external_lb(s) are fully provisioned
  depends_on = [null_resource.setup_primary_apiserver_lb]
}
