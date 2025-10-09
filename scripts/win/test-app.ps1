# scripts/win/test-app.ps1 - Deploy sample applications to test your cluster
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

Write-Host "=== Kubernetes Sample Application Deployment ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will help you deploy and test sample applications." -ForegroundColor White
Write-Host ""

# Check if kubectl is configured
try {
    $null = kubectl cluster-info 2>$null
    Write-Host "✅ Connected to Kubernetes cluster" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl is not configured to connect to a cluster." -ForegroundColor Red
    Write-Host "Please run .\scripts\win\setup.ps1 first to create your cluster." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Display menu
Write-Host "Choose a sample application to deploy:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1) Hello Kubernetes - Simple web app (Recommended for first test)" -ForegroundColor White
Write-Host "2) NGINX Demo - Basic NGINX web server" -ForegroundColor White
Write-Host "3) Guestbook - Multi-tier app with Redis (More advanced)" -ForegroundColor White
Write-Host "4) NGINX Vulnerable - Security demonstration (intentionally insecure)" -ForegroundColor White
Write-Host "5) NGINX Secure - Security best practices demo" -ForegroundColor White
Write-Host "6) Deploy all applications" -ForegroundColor White
Write-Host "7) Check status of deployed applications" -ForegroundColor White
Write-Host "8) Clean up all sample applications" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-8)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Deploying Hello Kubernetes application..." -ForegroundColor Cyan
        kubectl apply -f sample-apps/deployment.yaml
        
        Write-Host ""
        Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
        kubectl wait --for=condition=available --timeout=300s deployment/hello-kubernetes
        
        Write-Host ""
        Write-Host "🌐 Getting external IP address (this may take a minute)..." -ForegroundColor Cyan
        Write-Host "Waiting for LoadBalancer IP..." -ForegroundColor Yellow
        
        # Wait for external IP
        $found = $false
        for ($i = 1; $i -le 60; $i++) {
            $externalIp = kubectl get service hello-kubernetes -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
            if ($externalIp) {
                Write-Host ""
                Write-Host "✅ Application deployed successfully!" -ForegroundColor Green
                Write-Host ""
                Write-Host "🌐 Access your application at: http://$externalIp" -ForegroundColor Cyan
                Write-Host ""
                $found = $true
                break
            }
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 5
        }
        
        if (-not $found) {
            Write-Host ""
            Write-Host "⏳ LoadBalancer is still provisioning. Check the IP with:" -ForegroundColor Yellow
            Write-Host "  kubectl get service hello-kubernetes" -ForegroundColor White
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "🚀 Deploying NGINX Demo application..." -ForegroundColor Cyan
        kubectl apply -f sample-apps/nginx-demo.yaml
        
        Write-Host ""
        Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
        kubectl wait --for=condition=available --timeout=300s deployment/nginx-demo
        
        Write-Host ""
        Write-Host "✅ NGINX deployed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Get the external IP with:" -ForegroundColor Cyan
        Write-Host "  kubectl get service nginx-service" -ForegroundColor White
    }
    
    "3" {
        Write-Host ""
        Write-Host "🚀 Deploying Guestbook application (this has multiple components)..." -ForegroundColor Cyan
        kubectl apply -f sample-apps/guestbook.yaml
        
        Write-Host ""
        Write-Host "⏳ Waiting for deployments to be ready..." -ForegroundColor Yellow
        kubectl wait --for=condition=available --timeout=300s deployment/redis-master
        kubectl wait --for=condition=available --timeout=300s deployment/redis-replica
        kubectl wait --for=condition=available --timeout=300s deployment/guestbook
        
        Write-Host ""
        Write-Host "✅ Guestbook deployed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Get the external IP with:" -ForegroundColor Cyan
        Write-Host "  kubectl get service guestbook" -ForegroundColor White
    }
    
    "4" {
        Write-Host ""
        Write-Host "⚠️  SECURITY DEMONSTRATION - Intentionally Vulnerable App" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This deployment contains security vulnerabilities for educational purposes." -ForegroundColor Yellow
        Write-Host "DO NOT expose this to the internet!" -ForegroundColor Red
        Write-Host ""
        $confirm = Read-Host "Continue with vulnerable deployment? (yes/no)"
        
        if ($confirm -eq "yes") {
            Write-Host ""
            Write-Host "🚀 Deploying vulnerable NGINX application..." -ForegroundColor Cyan
            kubectl apply -f sample-app/nginx-vulnerable.yaml
            
            Write-Host ""
            Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
            kubectl wait --for=condition=available --timeout=300s deployment/nginx-vulnerable
            
            Write-Host ""
            Write-Host "✅ Vulnerable app deployed!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Get the external IP with:" -ForegroundColor Cyan
            Write-Host "  kubectl get service nginx-vulnerable" -ForegroundColor White
            Write-Host ""
            Write-Host "📚 See SECURITY-DEMO.md for demonstration scenarios" -ForegroundColor Cyan
        } else {
            Write-Host "Deployment cancelled." -ForegroundColor Yellow
        }
    }
    
    "7" {
        Write-Host ""
        Write-Host "✅ SECURITY BEST PRACTICES - Properly Secured App" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Deploying secure NGINX application..." -ForegroundColor Cyan
        kubectl apply -f sample-app/nginx-secure.yaml
        
        Write-Host ""
        Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
        kubectl wait --for=condition=available --timeout=300s deployment/nginx-secure
        
        Write-Host ""
        Write-Host "✅ Secure app deployed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Get the external IP with:" -ForegroundColor Cyan
        Write-Host "  kubectl get service nginx-secure" -ForegroundColor White
        Write-Host ""
        Write-Host "📚 See SECURITY-DEMO.md to compare with vulnerable version" -ForegroundColor Cyan
    }
    
    "6" {
        Write-Host ""
        Write-Host "🚀 Deploying all sample applications..." -ForegroundColor Cyan
        kubectl apply -f sample-apps/
        
        Write-Host ""
        Write-Host "⏳ Waiting for all deployments to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        Write-Host ""
        Write-Host "✅ All applications deployed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Check status with: .\scripts\test-app.ps1 (choose option 7)" -ForegroundColor Cyan
    }
    
    "5" {
        Write-Host ""
        Write-Host "📊 Checking status of all resources..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "=== Deployments ===" -ForegroundColor Yellow
        kubectl get deployments
        
        Write-Host ""
        Write-Host "=== Services ===" -ForegroundColor Yellow
        kubectl get services
        
        Write-Host ""
        Write-Host "=== Pods ===" -ForegroundColor Yellow
        kubectl get pods
        
        Write-Host ""
        Write-Host "To access web applications, use the EXTERNAL-IP from the services above." -ForegroundColor Cyan
    }
    
    "8" {
        Write-Host ""
        Write-Host "🗑️  Cleaning up all sample applications..." -ForegroundColor Cyan
        
        # Delete each application if it exists
        kubectl delete -f sample-apps/deployment.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-demo.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/guestbook.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-vulnerable.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-secure.yaml --ignore-not-found=true
        
        Write-Host ""
        Write-Host "✅ All sample applications have been removed." -ForegroundColor Green
    }
    
    default {
        Write-Host "Invalid choice. Please run the script again and choose 1-8." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== Useful Commands ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "View all resources:" -ForegroundColor White
Write-Host "  kubectl get all" -ForegroundColor Gray
Write-Host ""
Write-Host "View logs from a pod:" -ForegroundColor White
Write-Host "  kubectl logs <pod-name>" -ForegroundColor Gray
Write-Host ""
Write-Host "Describe a service:" -ForegroundColor White
Write-Host "  kubectl describe service <service-name>" -ForegroundColor Gray
Write-Host ""
Write-Host "Delete a specific app:" -ForegroundColor White
Write-Host "  kubectl delete -f sample-app/<filename>.yaml" -ForegroundColor Gray
Write-Host ""