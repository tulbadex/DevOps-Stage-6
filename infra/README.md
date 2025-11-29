# HNG Stage 6 Infrastructure

This directory contains the complete infrastructure setup for the HNG Stage 6 microservices application.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **Ansible** >= 2.9 installed
4. **SSH Key Pair** for EC2 access
5. **Domain Name** pointed to your server IP
6. **S3 Bucket** for Terraform state storage

## Quick Setup

1. **Configure Terraform Variables:**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Update S3 Backend:**
   Edit `terraform/main.tf` and update the S3 backend configuration with your bucket name.

3. **Deploy Everything:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## Manual Deployment Steps

### 1. Infrastructure Provisioning

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 2. Application Deployment (if needed manually)

```bash
cd ../ansible
ansible-playbook -i inventory.ini site.yml
```

## Architecture

- **VPC** with public subnet
- **EC2 Instance** (t3.medium) running Ubuntu 20.04
- **Security Groups** allowing HTTP, HTTPS, and SSH
- **Traefik** reverse proxy with automatic SSL
- **Docker Compose** orchestrating all services

## Services

- **Frontend** (Vue.js) - Port 80/443
- **Auth API** (Go) - `/api/auth`
- **Todos API** (Node.js) - `/api/todos`
- **Users API** (Java Spring Boot) - `/api/users`
- **Log Processor** (Python) - Background service
- **Redis** - Queue and cache

## CI/CD Features

- **Drift Detection** - Automatically detects infrastructure changes
- **Email Notifications** - Alerts on drift detection
- **Manual Approval** - Required for infrastructure changes
- **Idempotent Deployments** - Safe to run multiple times

## Monitoring

Access Traefik dashboard at: `http://your-domain:8080`

## Troubleshooting

1. **SSH Connection Issues:**
   - Verify security group allows SSH (port 22)
   - Check SSH key permissions (chmod 600)

2. **SSL Certificate Issues:**
   - Ensure domain points to server IP
   - Check Let's Encrypt rate limits

3. **Service Not Starting:**
   - Check Docker logs: `docker-compose logs [service-name]`
   - Verify environment variables in `.env`

## Security Notes

- SSH access restricted to your IP (update security group as needed)
- All HTTP traffic redirected to HTTPS
- Services isolated in Docker network
- Secrets managed via environment variables