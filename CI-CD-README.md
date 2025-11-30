# CI/CD Pipeline Documentation

This repository implements a comprehensive CI/CD pipeline for the HNG13 Stage 6 DevOps project with infrastructure drift detection and automated deployment.

## Pipeline Overview

### 1. Infrastructure Pipeline (`infrastructure.yml`)
**Triggers:**
- Push to main branch with changes in `infra/terraform/**` or `infra/ansible/**`
- Manual workflow dispatch

**Features:**
- ✅ Terraform drift detection with email alerts
- ✅ Manual approval for infrastructure changes
- ✅ Automatic Ansible deployment
- ✅ Idempotent infrastructure provisioning
- ✅ Success/failure email notifications

### 2. Application Pipeline (`application.yml`)
**Triggers:**
- Push to main branch with changes in service directories
- Changes to `docker-compose.yml` or `.env`
- Manual workflow dispatch

**Features:**
- ✅ Smart change detection (only deploys changed services)
- ✅ Docker build and test validation
- ✅ Automated deployment to existing infrastructure
- ✅ Service health verification
- ✅ Deployment notifications

## Required GitHub Secrets

Configure these secrets in your repository settings:

### AWS Configuration
```
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
SSH_KEY_NAME=your_ec2_key_pair_name
SSH_PRIVATE_KEY=your_private_key_content
```

### Application Configuration
```
DOMAIN=your-domain.duckdns.org
DUCKDNS_TOKEN=your_duckdns_token
EMAIL_ALERT=your-email@example.com
```

### Email Notifications (Gmail SMTP)
```
SMTP_USERNAME=your-gmail@gmail.com
SMTP_PASSWORD=your_app_password
```

## Workflow Behaviors

### Infrastructure Pipeline

#### No Drift Detected (Exit Code 0)
```
✅ Terraform Plan → No Changes
✅ Skip Manual Approval
✅ Run Ansible (idempotent)
✅ Send Success Email
```

#### Drift Detected (Exit Code 2)
```
🚨 Terraform Plan → Changes Found
📧 Send Drift Alert Email
⏸️ Wait for Manual Approval
✅ Apply Changes (after approval)
✅ Run Ansible Deployment
📧 Send Success Email
```

#### Error (Exit Code 1)
```
❌ Terraform Plan → Error
📧 Send Failure Email
🛑 Stop Pipeline
```

### Application Pipeline

#### Changes Detected
```
🔍 Detect Changed Services
🏗️ Build Only Changed Services
✅ Test Docker Compose Config
🚀 Deploy to Server
✅ Verify Deployment
📧 Send Success Email
```

#### No Changes
```
🔍 No Service Changes Detected
⏭️ Skip Build and Deployment
ℹ️ Log "No Changes" Message
```

## Email Notifications

### Drift Detection Alert
- **Subject:** 🚨 INFRASTRUCTURE DRIFT DETECTED
- **Content:** Detailed drift information, approval links
- **Action Required:** Manual review and approval

### Deployment Success
- **Subject:** ✅ Infrastructure/Application Deployment Successful
- **Content:** Deployment summary, application URLs, test credentials
- **Action Required:** None (informational)

### Deployment Failure
- **Subject:** ❌ Deployment Failed
- **Content:** Error details, troubleshooting steps
- **Action Required:** Investigation and retry

## Single Command Deployment

The entire setup works with a single Terraform command:

```bash
cd infra/terraform
terraform apply -auto-approve
```

This will:
1. ✅ Provision AWS infrastructure
2. ✅ Generate Ansible inventory
3. ✅ Run Ansible configuration
4. ✅ Deploy application with Docker Compose
5. ✅ Configure Traefik + SSL
6. ✅ Skip unchanged resources (idempotent)

## Manual Approval Process

When drift is detected:

1. **Email Alert Sent** - Check your email for drift notification
2. **GitHub Issue Created** - Automatic issue with approval instructions
3. **Review Required** - Download and review Terraform plan
4. **Approval Options:**
   - Comment `approved` on the issue to proceed
   - Comment `denied` to reject changes
   - Wait 24 hours for automatic timeout

## Monitoring and Alerts

### What Triggers Alerts
- Infrastructure drift detection
- Deployment failures
- Manual workflow runs (optional)

### Alert Channels
- 📧 Email notifications (immediate)
- 🐛 GitHub Issues (for tracking)
- 📊 GitHub Actions logs (detailed)

## Troubleshooting

### Common Issues

**Drift Detection False Positives:**
```bash
# Check Terraform state
terraform refresh
terraform show
```

**Deployment Failures:**
```bash
# Check server status
ssh -i key.pem ubuntu@server-ip
docker ps
docker logs container-name
```

**Email Not Received:**
- Check spam/junk folder
- Verify SMTP credentials
- Check GitHub Actions logs

### Debug Commands

```bash
# Test Terraform locally
cd infra/terraform
terraform plan

# Test Ansible locally
cd infra/ansible
ansible-playbook -i inventory playbook.yml --check

# Test application locally
docker compose up -d
curl http://localhost:8080
```

## Security Best Practices

### Secrets Management
- ✅ All sensitive data in GitHub Secrets
- ✅ SSH keys with proper permissions
- ✅ AWS credentials with minimal required permissions
- ✅ Email credentials using app passwords

### Infrastructure Security
- ✅ Manual approval for all infrastructure changes
- ✅ Drift detection prevents unauthorized changes
- ✅ Audit trail through GitHub Actions logs
- ✅ Encrypted communication (HTTPS/SSH)

### Access Control
- ✅ Repository owner approval required
- ✅ Branch protection on main branch
- ✅ Workflow concurrency controls
- ✅ Timeout limits on approvals

## Performance Optimizations

### Build Optimization
- ✅ Smart change detection (only build changed services)
- ✅ Docker layer caching
- ✅ Parallel service builds
- ✅ Artifact retention policies

### Deployment Optimization
- ✅ Idempotent operations (no unnecessary restarts)
- ✅ Health checks before completion
- ✅ Rollback capabilities
- ✅ Zero-downtime deployments

## Maintenance

### Regular Tasks
- Monitor email alerts and respond promptly
- Review GitHub Issues for approval requests
- Check workflow run history for patterns
- Update secrets when they expire

### Periodic Reviews
- Review and update Terraform configurations
- Update Ansible playbooks for security patches
- Review and optimize Docker images
- Test disaster recovery procedures

## Support

For issues with the CI/CD pipeline:

1. **Check GitHub Actions logs** for detailed error information
2. **Review email notifications** for context
3. **Check this documentation** for troubleshooting steps
4. **Create an issue** in the repository for help

---

**Pipeline Version:** 1.0  
**Last Updated:** $(date)  
**Maintainer:** DevOps Team