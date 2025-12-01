output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address of the EC2 instance"
}

output "public_dns" {
  value       = aws_instance.app_server.public_dns
  description = "The public DNS of the EC2 instance"
}

output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.app_server.public_ip}"
  description = "SSH command to connect to the instance"
}

# NEW
output "public_ip_raw" {
  value = aws_instance.app_server.public_ip
}

output "instance_ip" {
  value = aws_instance.app_server.public_ip
  description = "The public IP address for CI/CD pipeline"
}