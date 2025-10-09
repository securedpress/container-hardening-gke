# Quick Start Guide

## 🚀 Getting Started (5 Steps)

### 1. Install Tools
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads)
- kubectl (via gcloud: `gcloud components install kubectl`)

### 2. Setup GCP Project
```bash
# Create project at: https://console.cloud.google.com/
# Note your PROJECT_ID
```

### 3. Configure
```bash
# Copy the template
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and add your PROJECT_ID
```

### 4. Deploy Cluster
```bash
# Mac/Linux
./mac/setup.sh

# Windows
.\win\setup.ps1
```

### 5. Test with Sample App
```bash
# Mac/Linux
./mac/test-app.sh

# Windows
.\win\test-app.ps1
```

---

## 📝 Essential Commands Cheat Sheet

### Cluster Management
```bash
# View cluster info
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all

# View resources in all namespaces
kubectl get all -A
```

### Working with Pods
```bash
# List pods
kubectl get pods

# Describe a pod (detailed info)
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Follow logs in real-time
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash
```

### Working with Deployments
```bash
# List deployments
kubectl get deployments

# Scale a deployment
kubectl scale deployment <name> --replicas=5

# Update deployment image
kubectl set image deployment/<name> <container>=<new-image>

# View rollout status
kubectl rollout status deployment/<name>

# Rollback deployment
kubectl rollout undo deployment/<name>
```

### Working with Services
```bash
# List services
kubectl get services

# Get external IP
kubectl get service <service-name>

# Describe service
kubectl describe service <service-name>

# Port forward to local machine
kubectl port-forward service/<name> 8080:80
```

### Deploying Applications
```bash
# Apply a YAML file
kubectl apply -f deployment.yaml

# Apply all YAMLs in a directory
kubectl apply -f ./sample-app/

# Delete resources from YAML
kubectl delete -f deployment.yaml

# Create from command line
kubectl create deployment nginx --image=nginx

# Expose deployment as service
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

### Debugging
```bash
# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe for troubleshooting
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>

# Check resource usage
kubectl top nodes
kubectl top pods
```

---

## 🎯 Common Tasks

### Deploy the Hello Kubernetes App
```bash
kubectl apply -f sample-app/deployment.yaml
kubectl get service hello-kubernetes
# Wait for EXTERNAL-IP, then visit http://EXTERNAL-IP
```

### Check Application Status
```bash
kubectl get pods
kubectl get services
kubectl logs <pod-name>
```

### Scale an Application
```bash
kubectl scale deployment hello-kubernetes --replicas=5
kubectl get pods
```

### Update an Application
```bash
kubectl set image deployment/hello-kubernetes hello-kubernetes=nginx:latest
kubectl rollout status deployment/hello-kubernetes
```

### Delete an Application
```bash
kubectl delete -f sample-app/deployment.yaml
```

---

## 🔧 Terraform Commands

### Initialize Terraform
```bash
terraform init
```

### Preview Changes
```bash
terraform plan
```

### Apply Changes
```bash
terraform apply
```

### View Current State
```bash
terraform show
```

### Destroy Resources
```bash
terraform destroy
```

### View Outputs
```bash
terraform output
```

---

## 💰 Cost Management

### Stop Cluster (Save Money)
```bash
# Reduce to 0 nodes when not in use
gcloud container clusters resize security-demo-cluster --num-nodes=0 --zone=us-central1-a

# Start again when needed
gcloud container clusters resize security-demo-cluster --num-nodes=3 --zone=us-central1-a
```

### Delete Cluster (Stop All Charges)
```bash
# Mac/Linux
./cleanup.sh

# Windows
.\cleanup.ps1
```

### Check Costs
```bash
# View project billing
gcloud billing projects describe PROJECT_ID

# Visit: https://console.cloud.google.com/billing
```

---

## 🆘 Troubleshooting

### Cluster Not Accessible
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login

# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> --zone=<zone>
```

### Pods Not Starting
```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### LoadBalancer Stuck in Pending
```bash
# Wait 2-5 minutes for GCP to provision
kubectl get service <service-name> --watch

# Check service events
kubectl describe service <service-name>
```

### Can't Access Application
```bash
# Verify service has external IP
kubectl get service <service-name>

# Check firewall rules in GCP Console
# GKE should automatically create them

# Test with port-forward
kubectl port-forward service/<service-name> 8080:80
# Visit http://localhost:8080
```

---

## 📚 Learning Path

### Beginner
1. ✅ Deploy your cluster
2. ✅ Deploy Hello Kubernetes app
3. ✅ Access the app via external IP
4. ✅ View logs and pod details
5. ✅ Scale the deployment

### Intermediate
1. Deploy NGINX demo
2. Update the deployment with a new image
3. Create your own simple deployment
4. Use ConfigMaps and Secrets
5. Deploy the Guestbook app

### Advanced
1. Create your own multi-tier application
2. Implement health checks
3. Use persistent volumes
4. Set up ingress controllers
5. Implement autoscaling

---

## 🔗 Helpful Resources

- **Kubernetes Documentation:** https://kubernetes.io/docs/

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.