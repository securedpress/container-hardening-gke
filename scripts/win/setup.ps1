# scripts/win/setup.ps1 - Setup script for Windows
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

Write-Host "=== GKE Basic Cluster Setup Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
try {
    $null = Get-Command gcloud -ErrorAction Stop
    Write-Host "✅ gcloud CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ gcloud CLI is not installed." -ForegroundColor Red
    Write-Host "Please install it from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

# Check if terraform is installed
try {
    $null = Get-Command terraform -ErrorAction Stop
    Write-Host "✅ Terraform found" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform is not installed." -ForegroundColor Red
    Write-Host "Please install it from: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Navigate to terraform directory
Set-Location "$PSScriptRoot\..\..\terraform"

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "📝 Creating terraform.tfvars from template..." -ForegroundColor Yellow
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Host ""
    Write-Host "⚠️  Please edit terraform/terraform.tfvars and add your GCP project ID" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 0
}

# Get project ID from terraform.tfvars
$projectIdLine = Get-Content "terraform.tfvars" | Where-Object { $_ -match 'project_id' }
$projectId = ($projectIdLine -split '"')[1]

if ($projectId -eq "YOUR-GCP-PROJECT-ID") {
    Write-Host "⚠️  Please edit terraform.tfvars and replace YOUR-GCP-PROJECT-ID with your actual project ID" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Using GCP Project: $projectId" -ForegroundColor Cyan
Write-Host ""

# Authenticate with GCP
Write-Host "🔐 Authenticating with Google Cloud..." -ForegroundColor Cyan
gcloud auth application-default login

# Set the project
gcloud config set project $projectId

# Enable required APIs
Write-Host "🔧 Enabling required Google Cloud APIs..." -ForegroundColor Cyan
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

Write-Host ""
Write-Host "🚀 Initializing Terraform..." -ForegroundColor Cyan
terraform init

Write-Host ""
Write-Host "📋 Planning Terraform deployment..." -ForegroundColor Cyan
terraform plan

Write-Host ""
$confirm = Read-Host "Do you want to apply this Terraform plan? (yes/no)"

if ($confirm -eq "yes") {
    Write-Host ""
    Write-Host "🏗️  Creating your Kubernetes cluster (this may take 5-10 minutes)..." -ForegroundColor Cyan
    terraform apply -auto-approve
    
    Write-Host ""
    Write-Host "✅ Cluster created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Configuring kubectl..." -ForegroundColor Cyan
    
    # Get cluster details from terraform output
    $clusterName = terraform output -raw cluster_name
    $zoneLine = Get-Content "terraform.tfvars" | Where-Object { $_ -match 'zone' }
    $zone = ($zoneLine -split '"')[1]
    
    gcloud container clusters get-credentials $clusterName --zone=$zone --project=$projectId
    
    Write-Host ""
    Write-Host "🎉 Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use kubectl to interact with your cluster:" -ForegroundColor Cyan
    Write-Host "  kubectl get nodes" -ForegroundColor White
    Write-Host "  kubectl get pods -A" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Setup cancelled." -ForegroundColor Yellow
}