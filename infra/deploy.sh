#!/bin/bash

set -e

echo "🚀 Starting HNG Stage 6 Deployment..."

# Check if required files exist
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please create it from terraform.tfvars.example"
    exit 1
fi

# Navigate to terraform directory
cd terraform

echo "📋 Initializing Terraform..."
terraform init

echo "📊 Planning infrastructure changes..."
terraform plan -out=tfplan

echo "🏗️  Applying infrastructure changes..."
terraform apply -auto-approve

echo "✅ Deployment completed successfully!"
echo "🌐 Your application should be available at: https://$(terraform output -raw instance_public_dns)"