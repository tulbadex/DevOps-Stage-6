# HNG13 Stage 6 DevOps - Complete Deployment Guide

## Project Overview

This project demonstrates a comprehensive DevOps implementation for a microservices-based TODO application. The solution showcases Infrastructure as Code (IaC), containerization, CI/CD pipelines, and automated deployment strategies using modern DevOps tools and practices.

### Application Architecture

The TODO application consists of five interconnected microservices, each serving a specific purpose:

**Frontend Service (Vue.js)**
- Provides the user interface for the TODO application
- Built with Vue.js framework for reactive user interactions
- Serves as the entry point for users to interact with the system
- Communicates with backend APIs through HTTP requests

**Authentication API (Go)**
- Handles user authentication and authorization
- Generates and validates JWT tokens for secure API access
- Implements login/logout functionality
- Written in Go for high performance and concurrency

**TODOs API (Node.js)**
- Manages CRUD operations for TODO items
- Handles creating, reading, updating, and deleting tasks
- Logs operations to Redis queue for audit trails
- Built with Node.js for rapid development and scalability

**Users API (Java Spring Boot)**
- Manages user profile information
- Provides user data to other services
- Implements user management functionality
- Uses Spring Boot for enterprise-grade features

**Log Message Processor (Python)**
- Processes log messages from Redis queue
- Handles audit trails and system monitoring
- Prints processed messages to stdout for debugging
- Written in Python for data processing capabilities

**Supporting Services**
- **Redis**: Message queue for inter-service communication
- **Zipkin**: Distributed tracing for microservices monitoring
- **Traefik**: Reverse proxy and load balancer with SSL termination

## Infrastructure Design

### Cloud Infrastructure (AWS)

**Compute Resources**
- EC2 Instance: t3.medium (2 vCPU, 4GB RAM)
- Operating System: Ubuntu 22.04 LTS
- Storage: 20GB GP3 EBS volume with encryption
- Network: Default VPC with public subnet

**Security Configuration**
- Security Group with controlled access:
  - SSH (Port 22): Restricted access for management
  - HTTP (Port 80): Public access for web traffic
  - HTTPS (Port 443): Public access for secure web traffic
  - Traefik Dashboard (Port 8080): Restricted access for monitoring

**DNS and Domain Management**
- DuckDNS for dynamic DNS resolution
- Automatic IP updates when infrastructure changes
- SSL certificate management through Let's Encrypt

### Infrastructure as Code (Terraform)

**State Management**
- S3 backend for remote state storage
- State locking with DynamoDB (planned)
- Versioning enabled for state history
- Force destroy capability for cleanup

**Resource Organization**
- Modular Terraform configuration
- Separate files for different resource types
- Provider version constraints for consistency
- Default tags for resource management

## Containerization Strategy

### Docker Implementation

**Multi-Service Architecture**
Each microservice is containerized with its own Dockerfile optimized for the specific technology stack:

- **Frontend**: Node.js build environment with nginx serving
- **Auth API**: Go multi-stage build for minimal image size
- **TODOs API**: Node.js runtime with npm dependencies
- **Users API**: Java OpenJDK with Spring Boot
- **Log Processor**: Python runtime with minimal dependencies

**Docker Compose Orchestration**
- Service dependency management
- Network isolation with custom bridge network
- Volume mounts for persistent data
- Environment variable configuration
- Health checks for service readiness

### Reverse Proxy and SSL

**Traefik Configuration**
- Automatic service discovery through Docker labels
- Dynamic routing based on hostnames and paths
- SSL certificate automation with Let's Encrypt
- HTTP to HTTPS redirection
- CORS middleware for API access

**SSL Certificate Management**
- Automatic certificate generation and renewal
- TLS challenge validation
- Certificate storage in persistent volumes
- Fallback mechanisms for certificate issues

## CI/CD Pipeline Architecture

### Infrastructure Pipeline

**Terraform Workflow**
The infrastructure pipeline handles the provisioning and management of AWS resources:

1. **Initialization Phase**
   - Terraform backend configuration
   - Provider plugin installation
   - State file validation

2. **Planning Phase**
   - Drift detection between current and desired state
   - Change preview and validation
   - Security scanning of infrastructure changes

3. **Approval Process**
   - Manual approval for infrastructure changes
   - Email notifications for drift detection
   - GitHub issue creation for approval tracking

4. **Deployment Phase**
   - Terraform apply with approved changes
   - Resource provisioning and configuration
   - Output generation for dependent processes

5. **Configuration Phase**
   - Ansible inventory generation
   - SSH connectivity validation
   - System dependency installation
   - Application deployment preparation

### Application Pipeline

**Change Detection System**
The application pipeline implements intelligent change detection to optimize deployment efficiency:

- **Path-based Filtering**: Only deploys when application code changes
- **Service-specific Detection**: Identifies which microservices need updates
- **Dependency Mapping**: Understands service interdependencies
- **Skip Logic**: Avoids unnecessary deployments when only documentation changes

**Build and Test Phase**
1. **Docker Image Building**
   - Multi-stage builds for optimization
   - Layer caching for faster builds
   - Security scanning of images
   - Build artifact validation

2. **Configuration Validation**
   - Docker Compose syntax checking
   - Environment variable validation
   - Network configuration testing
   - Service dependency verification

**Deployment Process**
1. **Infrastructure Validation**
   - Server connectivity checks
   - Resource availability verification
   - Previous deployment cleanup

2. **Code Synchronization**
   - Git repository cloning/updating
   - Force pull to ensure latest changes
   - Branch verification and checkout

3. **Service Deployment**
   - Docker Compose service orchestration
   - Rolling updates with zero downtime
   - Health checks and readiness probes
   - Service dependency management

4. **SSL and Routing Configuration**
   - Traefik service registration
   - SSL certificate validation
   - Domain resolution verification
   - Route testing and validation

## Configuration Management (Ansible)

### System Dependencies

**Package Management**
- System package installation and updates
- Docker and Docker Compose installation
- Python dependencies for Ansible modules
- Security updates and patches

**User and Permission Management**
- Docker group membership for deployment user
- SSH key management and rotation
- File permissions and ownership
- Service account configuration

### Application Configuration

**Environment Management**
- Dynamic environment file generation
- Secret management and injection
- Service discovery configuration
- Database and external service connections

**Service Orchestration**
- Docker network creation and management
- Volume mounting and persistence
- Service startup order and dependencies
- Health monitoring and recovery

## Monitoring and Observability

### Distributed Tracing

**Zipkin Integration**
- Request tracing across microservices
- Performance bottleneck identification
- Service dependency mapping
- Error tracking and debugging

### Logging Strategy

**Centralized Logging**
- Docker container log aggregation
- Application-level logging
- System-level monitoring
- Error alerting and notification

### Health Monitoring

**Service Health Checks**
- HTTP endpoint monitoring
- Container health status
- Resource utilization tracking
- Automated recovery procedures

## Security Implementation

### Network Security

**Firewall Configuration**
- AWS Security Groups for network isolation
- Port-based access control
- IP whitelisting for administrative access
- DDoS protection through AWS infrastructure

### SSL/TLS Security

**Certificate Management**
- Automatic SSL certificate provisioning
- Certificate renewal automation
- Strong cipher suite configuration
- HSTS header implementation

### Secrets Management

**Environment Variables**
- Sensitive data isolation
- GitHub Secrets integration
- Runtime secret injection
- Access logging and auditing

## Issues Encountered and Solutions

### 1. S3 Backend State Management Issues

**Problem**: Terraform state bucket conflicts during creation and destruction
- Error: "BucketAlreadyOwnedByYou" when bucket exists
- Error: "NoSuchBucket" when trying to save state during destroy
- State corruption when backend becomes unavailable

**Root Cause**: 
- Terraform trying to create existing S3 bucket
- State save failures when bucket is deleted before state update
- Inconsistent state between local and remote backends

**Solution Implemented**:
```bash
# Automated destroy script with backend handling
- S3 bucket import for existing resources
- Lifecycle ignore_changes for bucket configuration
- Automated fallback to local backend during destroy
- State recovery mechanisms for corrupted state
```

**Technical Details**:
- Added `force_destroy = true` to S3 bucket resource
- Implemented conditional resource creation logic
- Created automated destroy script (`destroy.sh`)
- Added GitHub workflow for safe infrastructure destruction

### 2. Docker Permission Issues in Ansible

**Problem**: Docker commands failing with permission denied errors
- Error: "permission denied while trying to connect to Docker daemon socket"
- Ansible tasks failing when using `become_user: ubuntu`
- Docker group membership not taking effect immediately

**Root Cause**:
- User added to docker group but session not refreshed
- Ansible connection not recognizing new group membership
- Inconsistent permission handling between tasks

**Solution Implemented**:
```yaml
# Fixed Docker permissions in Ansible
- name: Add ubuntu user to docker group
  user:
    name: ubuntu
    groups: docker
    append: yes

- name: Reset ssh connection to allow user changes
  meta: reset_connection

# Use sudo -u ubuntu for Docker commands
- name: Build and start Docker Compose services
  shell: sudo -u ubuntu docker compose up -d --build --force-recreate
```

**Technical Details**:
- Added `meta: reset_connection` after group membership changes
- Replaced `become_user` with `sudo -u ubuntu` for Docker commands
- Ensured consistent user context across all Docker operations

### 3. SSL Certificate Generation Problems

**Problem**: Let's Encrypt certificates not generating or renewing properly
- SSL warnings in browsers despite certificate presence
- Certificate generation timeouts
- Domain resolution issues affecting ACME challenge

**Root Cause**:
- Domain not resolving to correct IP during certificate generation
- Traefik not properly configured for ACME challenge
- Certificate regeneration not triggered when needed

**Solution Implemented**:
```yaml
# Enhanced SSL certificate management
- name: Wait for domain to resolve
  shell: |
    for i in {1..30}; do
      RESOLVED_IP=$(dig +short {{ domain }} | tail -n1)
      if [ "$RESOLVED_IP" = "{{ ansible_host }}" ]; then
        echo "Domain resolved correctly!"
        break
      fi
      sleep 10
    done

- name: Trigger SSL certificate generation if needed
  shell: |
    if ! curl -I https://{{ domain }} --max-time 5 2>/dev/null | grep -q "HTTP/2 200"; then
      sudo -u ubuntu docker exec traefik rm -f /letsencrypt/acme.json
      sudo -u ubuntu docker compose restart traefik
    fi
```

**Technical Details**:
- Added domain resolution verification before certificate generation
- Implemented SSL certificate validation checks
- Created targeted Traefik restart instead of full service restart
- Added certificate regeneration logic when validation fails

### 4. Git Repository Synchronization Issues

**Problem**: Application deployments not reflecting latest code changes
- Server showing outdated code versions
- Git pull not fetching latest changes
- Cached Docker images preventing updates

**Root Cause**:
- Git pull only running conditionally when repository exists
- No force pull to override local changes
- Docker image caching preventing fresh builds

**Solution Implemented**:
```yaml
# Enhanced git synchronization
- name: Force git pull to ensure latest changes
  shell: |
    cd /home/ubuntu/todoapp
    git fetch --all
    git reset --hard origin/{{ github_branch }}
    git pull origin {{ github_branch }}

# Force Docker rebuild
- name: Build and start Docker Compose services
  shell: sudo -u ubuntu docker compose up -d --build --force-recreate
```

**Technical Details**:
- Added force git reset and pull operations
- Implemented `--force-recreate` flag for Docker Compose
- Ensured latest code is always deployed regardless of local state

### 5. Ansible Callback Configuration Issues

**Problem**: GitHub Actions failing with Ansible callback errors
- Error: "Invalid callback for stdout specified: yaml"
- Workflow failures in CI/CD environment
- Inconsistent Ansible configuration between local and remote

**Root Cause**:
- YAML callback plugin not available in GitHub Actions environment
- Different Ansible versions between development and CI environments
- Missing callback plugin dependencies

**Solution Implemented**:
```ini
# Fixed ansible.cfg configuration
[defaults]
host_key_checking = False
inventory = inventory
timeout = 30
stdout_callback = default  # Changed from yaml to default

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

**Technical Details**:
- Changed stdout callback from `yaml` to `default` for compatibility
- Added SSH connection optimization settings
- Ensured configuration works across different environments

### 6. Infrastructure State Persistence Issues

**Problem**: Application pipeline unable to find existing infrastructure
- Error: "No EC2 instance found in terraform state"
- Infrastructure and application pipelines not sharing state
- State inconsistency between pipeline runs

**Root Cause**:
- Missing S3 backend configuration initially
- State not persisted between GitHub Actions runs
- Different state locations for infrastructure and application pipelines

**Solution Implemented**:
```hcl
# Added S3 backend configuration
terraform {
  backend "s3" {
    bucket = "hng13-stage6-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

# State import for existing resources
terraform import aws_s3_bucket.terraform_state hng13-stage6-terraform-state
```

**Technical Details**:
- Configured S3 backend for state persistence
- Imported existing resources into Terraform state
- Ensured both pipelines use the same state location

## Best Practices Implemented

### Infrastructure as Code
- Version-controlled infrastructure definitions
- Immutable infrastructure principles
- Environment parity through code
- Automated resource provisioning

### CI/CD Pipeline Design
- Separation of infrastructure and application concerns
- Change-based deployment optimization
- Automated testing and validation
- Rollback capabilities and disaster recovery

### Security Practices
- Least privilege access principles
- Encrypted data transmission and storage
- Secret management through secure channels
- Regular security updates and patches

### Monitoring and Observability
- Comprehensive logging strategy
- Distributed tracing implementation
- Health check automation
- Performance monitoring and alerting

## Deployment Workflow

### Initial Setup
1. **Repository Configuration**
   - GitHub repository setup with proper branch protection
   - Secrets and variables configuration
   - Workflow permissions and environment setup

2. **Infrastructure Deployment**
   - Run infrastructure pipeline to provision AWS resources
   - Verify EC2 instance creation and network configuration
   - Validate DNS resolution and security group rules

3. **Application Deployment**
   - Trigger application pipeline for initial deployment
   - Monitor service startup and health checks
   - Verify SSL certificate generation and domain access

### Ongoing Operations
1. **Code Changes**
   - Push changes to trigger appropriate pipelines
   - Monitor deployment progress through GitHub Actions
   - Receive email notifications for deployment status

2. **Infrastructure Updates**
   - Modify Terraform configurations as needed
   - Review and approve infrastructure changes
   - Monitor drift detection and remediation

3. **Maintenance Operations**
   - Regular security updates through Ansible
   - SSL certificate renewal monitoring
   - Performance optimization and scaling

## Troubleshooting Guide

### Common Issues and Solutions

**Pipeline Failures**
- Check GitHub Actions logs for detailed error messages
- Verify AWS credentials and permissions
- Validate Terraform and Ansible syntax

**SSL Certificate Issues**
- Verify domain resolution to correct IP address
- Check Traefik logs for ACME challenge failures
- Restart Traefik service if certificate generation stalls

**Application Connectivity**
- Verify Docker container health status
- Check network connectivity between services
- Validate environment variable configuration

**State Management Problems**
- Use automated destroy script for clean teardown
- Import existing resources if state becomes inconsistent
- Backup and restore state files when necessary

## Future Enhancements

### Scalability Improvements
- Implement auto-scaling groups for high availability
- Add load balancing for multiple application instances
- Implement database clustering and replication

### Security Enhancements
- Implement WAF (Web Application Firewall)
- Add vulnerability scanning to CI/CD pipeline
- Implement secrets rotation automation

### Monitoring Improvements
- Add Prometheus and Grafana for metrics collection
- Implement log aggregation with ELK stack
- Add application performance monitoring (APM)

### Operational Excellence
- Implement blue-green deployment strategy
- Add automated backup and disaster recovery
- Implement infrastructure cost optimization

## Conclusion

This DevOps implementation demonstrates a comprehensive approach to modern application deployment, incorporating industry best practices for infrastructure management, containerization, and CI/CD automation. The solution addresses real-world challenges through robust error handling, automated recovery mechanisms, and scalable architecture design.

The project showcases the integration of multiple technologies and tools to create a production-ready deployment pipeline that can serve as a foundation for enterprise-grade applications. The documented issues and solutions provide valuable insights for troubleshooting and continuous improvement of the deployment process.