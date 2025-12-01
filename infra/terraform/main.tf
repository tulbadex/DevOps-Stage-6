provider "aws" {
  region = var.aws_region
}

locals {
  security_group_id = length(data.aws_security_groups.existing_sg.ids) > 0 ? data.aws_security_groups.existing_sg.ids[0] : aws_security_group.app_sg[0].id
}

resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [local.security_group_id]
  associate_public_ip_address = true
  user_data                   = base64encode(templatefile("${path.module}/user_data.sh", {}))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  /* Ansible deployment after server creation */
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Waiting for SSH on ${self.public_ip} …"
      for i in {1..120}; do
        ssh -i ${var.private_key_path} \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o BatchMode=yes \
            -o ConnectTimeout=30 \
            -o ServerAliveInterval=60 \
            -o ServerAliveCountMax=10 \
            -o LogLevel=ERROR \
            ubuntu@${self.public_ip} echo OK && break || sleep 10
      done
      echo "Waiting for system initialization to complete..."
      sleep 120
      echo "Writing inventory …"
      cat > ../ansible/inventory << EOF
[app_servers]
${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path} ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[app_servers:vars]
domain=${var.domain}
email=${var.email}
duckdns_token=${var.duckdns_token}
github_repo=${var.github_repo}
github_branch=${var.github_branch}
EOF
      echo "Running Ansible …"
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml -vv
    EOT
    environment = {
      DOMAIN         = var.domain
      EMAIL          = var.email
      DUCKDNS_TOKEN  = var.duckdns_token
      GITHUB_REPO    = var.github_repo
      GITHUB_BRANCH  = var.github_branch
    }
    when = create
  }

  tags = {
    Name   = var.instance_name
    Domain = var.domain
  }

  lifecycle {
    ignore_changes = [user_data]
    create_before_destroy = false
  }
}

/*------------------------------------------------
 Outputs
------------------------------------------------*/
output "application_url" {
  value = "https://${var.domain}"   # <= now gives the real URL
}