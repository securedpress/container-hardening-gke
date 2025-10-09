# scripts/win/cleanup.ps1 - Cleanup script to destroy the cluster and save costs
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

Write-Host "=== GKE Cluster Cleanup Script ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  WARNING: This will DELETE your Kubernetes cluster and all resources!" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Are you sure you want to continue? (yes/no)"

if ($confirm -eq "yes") {
    Write-Host ""
    Write-Host "🗑️  Destroying Terraform resources..." -ForegroundColor Cyan
    
    # Navigate to terraform directory
    Set-Location "$PSScriptRoot\..\..\terraform"
    
    terraform destroy
    
    Write-Host ""
    Write-Host "✅ Cleanup complete! Your cluster has been deleted." -ForegroundColor Green
    Write-Host "💰 This will stop incurring charges from Google Cloud." -ForegroundColor Green
} else {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
}