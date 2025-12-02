#!/bin/bash

# Script to empty S3 bucket before destroy
BUCKET_NAME="hng13-stage6-terraform-state"

echo "Emptying S3 bucket: $BUCKET_NAME"

# Delete all object versions
aws s3api list-object-versions --bucket $BUCKET_NAME --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text | while read key version; do
    if [ ! -z "$key" ] && [ ! -z "$version" ]; then
        echo "Deleting version $version of $key"
        aws s3api delete-object --bucket $BUCKET_NAME --key "$key" --version-id "$version"
    fi
done

# Delete all delete markers
aws s3api list-object-versions --bucket $BUCKET_NAME --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text | while read key version; do
    if [ ! -z "$key" ] && [ ! -z "$version" ]; then
        echo "Deleting delete marker $version of $key"
        aws s3api delete-object --bucket $BUCKET_NAME --key "$key" --version-id "$version"
    fi
done

echo "Bucket emptied successfully"