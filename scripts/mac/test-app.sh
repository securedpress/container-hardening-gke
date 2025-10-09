#!/bin/bash
# scripts/mac/test-app.sh - Deploy sample applications to test your cluster
#
# Author: Jose Perez
# Company: SecuredPress LLC
# GitHub: https://github.com/securedpress
# License: MIT

set -e

echo "=== Kubernetes Sample Application Deployment ==="
echo ""
echo "This script will help you deploy and test sample applications."
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl is not configured to connect to a cluster."
    echo "Please run ./scripts/mac/setup.sh first to create your cluster."
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"
echo ""

# Display menu
echo "Choose a sample application to deploy:"
echo ""
echo "1) Hello Kubernetes - Simple web app (Recommended for first test)"
echo "2) NGINX Demo - Basic NGINX web server"
echo "3) Guestbook - Multi-tier app with Redis (More advanced)"
echo "4) NGINX Vulnerable - Security demonstration (intentionally insecure)"
echo "5) NGINX Secure - Security best practices demo"
echo "6) Deploy all applications"
echo "7) Check status of deployed applications"
echo "8) Clean up all sample applications"
echo ""

read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Deploying Hello Kubernetes application..."
        kubectl apply -f sample-apps/deployment.yaml
        
        echo ""
        echo "⏳ Waiting for deployment to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/hello-kubernetes
        
        echo ""
        echo "🌐 Getting external IP address (this may take a minute)..."
        echo "Run this command to get the IP when ready:"
        echo "  kubectl get service hello-kubernetes"
        echo ""
        echo "Waiting for LoadBalancer IP..."
        
        # Wait for external IP
        for i in {1..60}; do
            EXTERNAL_IP=$(kubectl get service hello-kubernetes -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
            if [ ! -z "$EXTERNAL_IP" ]; then
                echo ""
                echo "✅ Application deployed successfully!"
                echo ""
                echo "🌐 Access your application at: http://$EXTERNAL_IP"
                echo ""
                break
            fi
            echo -n "."
            sleep 5
        done
        
        if [ -z "$EXTERNAL_IP" ]; then
            echo ""
            echo "⏳ LoadBalancer is still provisioning. Check the IP with:"
            echo "  kubectl get service hello-kubernetes"
        fi
        ;;
        
    2)
        echo ""
        echo "🚀 Deploying NGINX Demo application..."
        kubectl apply -f sample-apps/nginx-demo.yaml
        
        echo ""
        echo "⏳ Waiting for deployment to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/nginx-demo
        
        echo ""
        echo "✅ NGINX deployed successfully!"
        echo ""
        echo "Get the external IP with:"
        echo "  kubectl get service nginx-service"
        ;;
        
    3)
        echo ""
        echo "🚀 Deploying Guestbook application (this has multiple components)..."
        kubectl apply -f sample-apps/guestbook.yaml
        
        echo ""
        echo "⏳ Waiting for deployments to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/redis-master
        kubectl wait --for=condition=available --timeout=300s deployment/redis-replica
        kubectl wait --for=condition=available --timeout=300s deployment/guestbook
        
        echo ""
        echo "✅ Guestbook deployed successfully!"
        echo ""
        echo "Get the external IP with:"
        echo "  kubectl get service guestbook"
        ;;
        
    4)
        echo ""
        echo "⚠️  SECURITY DEMONSTRATION - Intentionally Vulnerable App"
        echo ""
        echo "This deployment contains security vulnerabilities for educational purposes."
        echo "DO NOT expose this to the internet!"
        echo ""
        read -p "Continue with vulnerable deployment? (yes/no): " confirm
        
        if [ "$confirm" == "yes" ]; then
            echo ""
            echo "🚀 Deploying vulnerable NGINX application..."
            kubectl apply -f sample-apps/nginx-vulnerable.yaml
            
            echo ""
            echo "⏳ Waiting for deployment to be ready..."
            kubectl wait --for=condition=available --timeout=300s deployment/nginx-vulnerable
            
            echo ""
            echo "✅ Vulnerable app deployed!"
            echo ""
            echo "Get the external IP with:"
            echo "  kubectl get service nginx-vulnerable"
            echo ""
            echo "📚 See SECURITY-DEMO.md for demonstration scenarios"
        else
            echo "Deployment cancelled."
        fi
        ;;
        
    7)
        echo ""
        echo "✅ SECURITY BEST PRACTICES - Properly Secured App"
        echo ""
        echo "🚀 Deploying secure NGINX application..."
        kubectl apply -f sample-apps/nginx-secure.yaml
        
        echo ""
        echo "⏳ Waiting for deployment to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/nginx-secure
        
        echo ""
        echo "✅ Secure app deployed!"
        echo ""
        echo "Get the external IP with:"
        echo "  kubectl get service nginx-secure"
        echo ""
        echo "📚 See SECURITY-DEMO.md to compare with vulnerable version"
        ;;
        
    6)
        echo ""
        echo "🚀 Deploying all sample applications..."
        kubectl apply -f sample-apps/
        
        echo ""
        echo "⏳ Waiting for all deployments to be ready..."
        sleep 10
        
        echo ""
        echo "✅ All applications deployed!"
        echo ""
        echo "Check status with: ./scripts/mac/test-app.sh (choose option 7)"
        ;;
        
    5)
        echo ""
        echo "📊 Checking status of all resources..."
        echo ""
        echo "=== Deployments ==="
        kubectl get deployments
        
        echo ""
        echo "=== Services ==="
        kubectl get services
        
        echo ""
        echo "=== Pods ==="
        kubectl get pods
        
        echo ""
        echo "To access web applications, use the EXTERNAL-IP from the services above."
        ;;
        
    8)
        echo ""
        echo "🗑️  Cleaning up all sample applications..."
        
        # Delete each application if it exists
        kubectl delete -f sample-apps/deployment.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-demo.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/guestbook.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-vulnerable.yaml --ignore-not-found=true
        kubectl delete -f sample-apps/nginx-secure.yaml --ignore-not-found=true
        
        echo ""
        echo "✅ All sample applications have been removed."
        ;;
        
    *)
        echo "Invalid choice. Please run the script again and choose 1-8."
        exit 1
        ;;
esac

echo ""
echo "=== Useful Commands ==="
echo ""
echo "View all resources:"
echo "  kubectl get all"
echo ""
echo "View logs from a pod:"
echo "  kubectl logs <pod-name>"
echo ""
echo "Describe a service:"
echo "  kubectl describe service <service-name>"
echo ""
echo "Delete a specific app:"
echo "  kubectl delete -f sample-app/<filename>.yaml"
echo ""