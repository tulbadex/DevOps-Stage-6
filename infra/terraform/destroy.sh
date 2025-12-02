#!/bin/bash

# Enhanced Terraform destroy script that handles S3 backend issues and errored state

echo "Starting Terraform destroy process..."

# Check if errored.tfstate exists from previous failed operation
if [ -f "errored.tfstate" ]; then
    echo "⚠️ Found errored.tfstate from previous failed operation"
    echo "Attempting to recover state..."
    
    # Disable S3 backend temporarily
    if [ -f "backend.tf" ]; then
        mv backend.tf backend.tf.disabled
        echo "Disabled S3 backend configuration"
    fi
    
    # Clean up and reinitialize
    rm -rf .terraform .terraform.lock.hcl
    terraform init
    
    # Copy errored state to current state
    cp errored.tfstate terraform.tfstate
    
    # Try destroy with recovered state
    if terraform destroy -auto-approve; then
        echo "✅ Destroy completed using recovered state!"
        rm -f errored.tfstate terraform.tfstate terraform.tfstate.backup
        # Restore backend config
        [ -f "backend.tf.disabled" ] && mv backend.tf.disabled backend.tf
        exit 0
    fi
fi

# First, try normal destroy with S3 backend
if terraform destroy -auto-approve; then
    echo "✅ Destroy completed successfully!"
    exit 0
fi

echo "⚠️ Normal destroy failed, likely due to S3 backend issues"
echo "Attempting recovery with local backend..."

# Disable S3 backend
if [ -f "backend.tf" ]; then
    mv backend.tf backend.tf.disabled
    echo "Disabled S3 backend configuration"
fi

# Clean up terraform state
rm -rf .terraform .terraform.lock.hcl

# Reinitialize with local backend
terraform init

# Import existing resources if they exist
echo "Checking for existing resources to import..."

# Try to import existing security group
SG_ID=$(aws ec2 describe-security-groups --group-names "hng-stage6-web-server-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "None")
if [ "$SG_ID" != "None" ] && [ "$SG_ID" != "null" ]; then
    echo "Importing existing security group: $SG_ID"
    terraform import aws_security_group.app_sg $SG_ID || echo "Import failed or already exists"
fi

# Try to import existing instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=hng-stage6-web-server" "Name=instance-state-name,Values=running,stopped" --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || echo "None")
if [ "$INSTANCE_ID" != "None" ] && [ "$INSTANCE_ID" != "null" ]; then
    echo "Importing existing instance: $INSTANCE_ID"
    terraform import aws_instance.app_server $INSTANCE_ID || echo "Import failed or already exists"
fi

# Try to import S3 bucket if it exists
if aws s3api head-bucket --bucket "hng13-stage6-terraform-state" 2>/dev/null; then
    echo "Importing existing S3 bucket"
    terraform import aws_s3_bucket.terraform_state hng13-stage6-terraform-state || echo "Import failed or already exists"
fi

# Try destroy with local state
if terraform destroy -auto-approve; then
    echo "✅ Destroy completed with local backend!"
else
    echo "❌ Destroy failed even with local backend"
    echo "Manual cleanup may be required"
    echo "Check AWS console for remaining resources:"
    echo "- EC2 instances with tag Name=hng-stage6-web-server"
    echo "- Security groups named hng-stage6-web-server-sg"
    echo "- S3 bucket hng13-stage6-terraform-state"
fi

# Restore backend config
[ -f "backend.tf.disabled" ] && mv backend.tf.disabled backend.tf

# Clean up local state files
rm -f terraform.tfstate terraform.tfstate.backup errored.tfstate

echo "🧹 Cleanup completed"