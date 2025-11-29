variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hng-stage6"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Ubuntu 20.04 LTS
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "public_key" {
  description = "Public key for EC2 access"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

variable "github_username" {
  description = "GitHub username for repository"
  type        = string
}

variable "repo_name" {
  description = "Repository name"
  type        = string
  default     = "hng-stage6"
}

variable "duckdns_subdomain" {
  description = "DuckDNS subdomain (without .duckdns.org)"
  type        = string
  default     = ""
}

variable "duckdns_token" {
  description = "DuckDNS token for domain updates"
  type        = string
  default     = ""
  sensitive   = true
}