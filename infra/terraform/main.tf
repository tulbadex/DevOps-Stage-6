provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data                   = base64encode(templatefile("${path.module}/user_data.sh", {}))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  /* one-shot Ansible run */
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
      ../scripts/gen_inventory.sh ${self.public_ip} > ../ansible/inventory
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
  }
}

/*------------------------------------------------
 Outputs
------------------------------------------------*/
output "instance_ip" {
  value = aws_instance.app_server.public_ip
}

output "application_url" {
  value = "https://${var.domain}"   # <= now gives the real URL
}