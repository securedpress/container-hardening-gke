#!/bin/bash
# scripts/mac/setup.sh - Setup script for Mac/Linux
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

set -e

echo "=== GKE Basic Cluster Setup Script ==="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed."
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed."
    echo "Please install it from: https://www.terraform.io/downloads"
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Navigate to terraform directory
cd "$(dirname "$0")/../../terraform" || exit 1

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from template..."
    cp terraform.tfvars.example terraform.tfvars
    echo ""
    echo "⚠️  Please edit terraform/terraform.tfvars and add your GCP project ID"
    echo "Then run this script again."
    exit 0
fi

# Get project ID from terraform.tfvars
PROJECT_ID=$(grep 'project_id' terraform.tfvars | cut -d'"' -f2)

if [ "$PROJECT_ID" == "YOUR-GCP-PROJECT-ID" ]; then
    echo "⚠️  Please edit terraform.tfvars and replace YOUR-GCP-PROJECT-ID with your actual project ID"
    exit 1
fi

echo "📋 Using GCP Project: $PROJECT_ID"
echo ""

# Authenticate with GCP
echo "🔐 Authenticating with Google Cloud..."
gcloud auth application-default login

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required Google Cloud APIs..."
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

echo ""
echo "🚀 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning Terraform deployment..."
terraform plan

echo ""
read -p "Do you want to apply this Terraform plan? (yes/no): " CONFIRM

if [ "$CONFIRM" == "yes" ]; then
    echo ""
    echo "🏗️  Creating your Kubernetes cluster (this may take 5-10 minutes)..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Cluster created successfully!"
    echo ""
    echo "🔧 Configuring kubectl..."
    
    # Get cluster details from terraform output
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    ZONE=$(grep 'zone' terraform.tfvars | cut -d'"' -f2)
    
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "You can now use kubectl to interact with your cluster:"
    echo "  kubectl get nodes"
    echo "  kubectl get pods -A"
    echo ""
else
    echo "Setup cancelled."
fi