# Security Group
# --- VPC / SG ---------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# Import existing security group if it exists
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["${var.instance_name}-sg"]
  }
}

resource "aws_security_group" "app_sg" {
  count       = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1
  name        = "${var.instance_name}-sg"
  description = "Allow traffic for ToDo application"
  vpc_id      = data.aws_vpc.default.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Traefik Dashboard (optional, restrict in production)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Use existing security group if available, otherwise use the new one
data "aws_security_group" "app_sg" {
  name = "${var.instance_name}-sg"
  depends_on = [aws_security_group.app_sg]
}