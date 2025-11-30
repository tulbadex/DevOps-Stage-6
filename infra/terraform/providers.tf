terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88.0"
    }
    local = ">= 2.4"
    tls   = ">= 4.0"
  }
}