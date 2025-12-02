terraform {
  backend "s3" {
    bucket = "hng13-stage6-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "HNG13-DevOps-Stage6"
      ManagedBy   = "Terraform"
      Environment = "production"
    }
  }
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "hng13-stage6-terraform-state"
  force_destroy = true
  
  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
  
  lifecycle {
    ignore_changes = [versioning_configuration]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
  lifecycle {
    ignore_changes = [rule]
  }
}

locals {
  security_group_id = aws_security_group.app_sg.id
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
ansible_python_interpreter=/usr/bin/python3
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