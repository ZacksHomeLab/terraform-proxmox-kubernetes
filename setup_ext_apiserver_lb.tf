locals {

  prepare_ext_apiserver_script_template = "${path.module}/templates/prepare_ext_apiserver_lb.sh.tftpl"
  prepare_ext_apiserver_script_rendered = "${path.module}/rendered/prepare_ext_apiserver_lb.sh"
  prepare_ext_apiserver_script_dest     = "/tmp/${basename(local.prepare_ext_apiserver_script_rendered)}"

  # Must have Control Planes in order to create an External API Server LB
  create_ext_apiserver_lb = local.control_plane_count > 0 && var.create_ext_apiserver_lb ? 1 : 0
}

resource "random_password" "ext_apiserver_keepalived_pass" {
  count = local.create_ext_apiserver_lb
  # Keepalived truncates the password to 8 characters
  length  = 8
  special = false

  # By default, random providers generate new values ONLY if they're deleted. So,
  #   it may not be necessary to have a 'keeper' or 'trigger'
  /*keepers = {
    vm_id = module.ext_apiserver_lb[0].vmid
  }*/
}

resource "local_file" "prepare_ext_apiserver_lb" {
  count = local.create_ext_apiserver_lb

  content = templatefile(local.prepare_ext_apiserver_script_template, {
    apiserver_dest_port = var.apiserver_dest_port
    lb_port             = var.apiserver_lb_port
    keepalive_router_id = var.keepalive_router_id
    keepalive_pass      = random_password.ext_apiserver_keepalived_pass[0].result
    virtual_ip          = local.apiserver_lb_virtual_ip
    vms                 = module.control_planes
  })

  filename = local.prepare_ext_apiserver_script_rendered
}

resource "null_resource" "setup_ext_apiserver_lb" {
  count = local.ext_apiserver_lb_count

  connection {
    host        = module.ext_apiserver_lb[count.index].ssh_settings.ssh_host
    private_key = local.private_key
    type        = "ssh"
    user        = module.ext_apiserver_lb[count.index].ssh_settings.ssh_user
  }

  provisioner "file" {
    source      = local_file.prepare_ext_apiserver_lb[0].filename
    destination = local.prepare_ext_apiserver_script_dest
  }

  /*
    prepare_ext_apiserver_lb.sh accepts 3 parameters
      1. The Current API Server LB's IP Address
      2. The KeepaliveD password
      3. Set the state to 'MASTER' if this is the first Load Balancer, otherwise
          set the remaining LB(s) to 'BACKUP'.
  */
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo chmod +x ${local.prepare_ext_apiserver_script_dest} && \
        sudo ${local.prepare_ext_apiserver_script_dest} \
        ${module.ext_apiserver_lb[count.index].ip} \
        ${random_password.ext_apiserver_keepalived_pass[0].result} \
        ${module.ext_apiserver_lb[count.index].ip == module.ext_apiserver_lb[0].ip ? "MASTER" : "BACKUP"} && \
        sudo rm ${local.prepare_ext_apiserver_script_dest}
      EOT
      ,
    ]
  }

  triggers = {
    vmid = module.ext_apiserver_lb[count.index].vmid
  }

  # Prevent this resource from running until external_lb(s) are fully provisioned
  depends_on = [module.ext_apiserver_lb]
}
