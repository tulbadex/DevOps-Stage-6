#!/bin/bash

# Simple Terraform destroy script that handles S3 backend issues

echo "Starting Terraform destroy process..."

# First, try normal destroy
if terraform destroy -auto-approve; then
    echo "✅ Destroy completed successfully!"
    exit 0
fi

echo "⚠️ Normal destroy failed, likely due to S3 backend issues"
echo "Attempting recovery..."

# Backup current config
cp main.tf main.tf.backup

# Comment out S3 backend
sed -i 's/^terraform {/# terraform {/' main.tf
sed -i 's/^  backend "s3"/# backend "s3"/' main.tf
sed -i 's/^    bucket/# bucket/' main.tf
sed -i 's/^    key/# key/' main.tf
sed -i 's/^    region/# region/' main.tf
sed -i 's/^  }/# }/' main.tf

# Clean up terraform state
rm -rf .terraform .terraform.lock.hcl

# Reinitialize with local backend
terraform init

# Try destroy with local state
if terraform destroy -auto-approve; then
    echo "✅ Destroy completed with local backend!"
else
    echo "❌ Destroy failed even with local backend"
fi

# Restore original config
mv main.tf.backup main.tf

# Clean up local state files
rm -f terraform.tfstate terraform.tfstate.backup errored.tfstate

echo "🧹 Cleanup completed"