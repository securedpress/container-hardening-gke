#!/bin/bash
# scripts/mac/cleanup.sh - Cleanup script to destroy the cluster and save costs
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

set -e

echo "=== GKE Cluster Cleanup Script ==="
echo ""
echo "⚠️  WARNING: This will DELETE your Kubernetes cluster and all resources!"
echo ""

read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" == "yes" ]; then
    echo ""
    echo "🗑️  Destroying Terraform resources..."
    
    # Navigate to terraform directory
    cd "$(dirname "$0")/../../terraform" || exit 1
    
    terraform destroy
    
    echo ""
    echo "✅ Cleanup complete! Your cluster has been deleted."
    echo "💰 This will stop incurring charges from Google Cloud."
else
    echo "Cleanup cancelled."
fi