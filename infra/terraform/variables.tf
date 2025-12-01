variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 in us-east-2"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "ssh_key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL for the application"
  type        = string
}

variable "email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

variable "domain" {
  description = "Domain to the application"
  type        = string
}

variable "email_ses" { 
  description = "your email for drift alerts" 
  type        = string
}

variable "github_branch" { 
  description = "the github branch to be used" 
  type        = string
  default     = "main" 
}

variable "duckdns_token" {
  description = "DuckDNS token for dynamic DNS updates"
  type        = string
  default     = ""
  sensitive   = true
}