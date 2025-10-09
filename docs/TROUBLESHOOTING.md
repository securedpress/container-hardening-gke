# Troubleshooting Guide

Complete troubleshooting guide for the GKE Kubernetes Security Demo project.

## 📋 Table of Contents

- [Prerequisites Issues](#prerequisites-issues)
- [Terraform Issues](#terraform-issues)
- [GCP/GKE Issues](#gcpgke-issues)
- [Script Issues](#script-issues)
- [Application Deployment Issues](#application-deployment-issues)
- [Network/Connectivity Issues](#networkconnectivity-issues)
- [Cost Issues](#cost-issues)
- [Security Demo Issues](#security-demo-issues)

---

## Prerequisites Issues

### Issue: gcloud command not found

**Symptoms:**
```bash
./scripts/mac/setup.sh
# Output: gcloud: command not found
```

**Solution:**

**Mac:**
```bash
# Install via Homebrew
brew install --cask google-cloud-sdk

# Or download from:
# https://cloud.google.com/sdk/docs/install
```

**Windows:**
```powershell
# Download installer from:
# https://cloud.google.com/sdk/docs/install

# Or use Chocolatey
choco install gcloudsdk
```

**Verify:**
```bash
gcloud --version
# Should show: Google Cloud SDK 450.0.0+
```

---

### Issue: terraform command not found

**Symptoms:**
```bash
terraform --version
# Output: terraform: command not found
```

**Solution:**

**Mac:**
```bash
brew install terraform
```

**Windows:**
```powershell
# Download from terraform.io
# Or use Chocolatey
choco install terraform
```

**Linux:**
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify:**
```bash
terraform --version
# Should show: Terraform v1.6.0 or higher
```

---

### Issue: kubectl command not found

**Symptoms:**
```bash
kubectl version
# Output: kubectl: command not found
```

**Solution:**
```bash
# Install via gcloud
gcloud components install kubectl

# Or via package manager
# Mac:
brew install kubectl

# Windows:
choco install kubernetes-cli
```

**Verify:**
```bash
kubectl version --client
```

---

## Terraform Issues

### Issue: terraform.tfvars not found

**Symptoms:**
```bash
./scripts/mac/setup.sh
# Error: No value for required variable "project_id"
```

**Cause:** Didn't copy the example file

**Solution:**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit the file
nano terraform.tfvars
# or
code terraform.tfvars

# Add your project ID:
project_id = "your-actual-project-id"
```

---

### Issue: Error locking state file

**Symptoms:**
```
Error: Error acquiring the state lock
```

**Cause:** Previous terraform command didn't complete properly

**Solution:**
```bash
# Force unlock (use the Lock ID from error message)
cd terraform
terraform force-unlock LOCK_ID

# Example:
terraform force-unlock 1234567890-abcd-1234-5678-1234567890ab
```

---

### Issue: Provider authentication error

**Symptoms:**
```
Error: google: could not find default credentials
```

**Cause:** Not authenticated with GCP

**Solution:**
```bash
# Authenticate
gcloud auth login

# Set application default credentials
gcloud auth application-default login

# Set project
gcloud config set project YOUR-PROJECT-ID

# Verify
gcloud auth list
```

---

### Issue: Terraform version mismatch

**Symptoms:**
```
Error: Unsupported Terraform Core version
```

**Solution:**
```bash
# Check current version
terraform --version

# Upgrade terraform
# Mac:
brew upgrade terraform

# Windows:
choco upgrade terraform

# Or download latest from terraform.io
```

---

### Issue: Cannot destroy cluster (deletion_protection)

**Symptoms:**
```
Error: Cannot destroy cluster because deletion_protection is set to true
```

**Solution:**

**Option 1: Update Terraform (Recommended)**
```bash
cd terraform

# Edit main.tf and add:
# deletion_protection = false

terraform apply  # This updates the cluster
# Type 'yes' when prompted

# Now destroy
cd ..
./scripts/mac/cleanup.sh  # or .\scripts\win\cleanup.ps1
```

**Option 2: Use gcloud**
```bash
# Disable deletion protection
gcloud container clusters update YOUR-CLUSTER-NAME \
  --zone=us-central1-a \
  --no-enable-deletion-protection

# Then destroy via terraform
terraform destroy
```

---

### Issue: Insufficient regional quota

**Symptoms:**
```
Error: Quota 'IN_USE_ADDRESSES' exceeded. Limit: 8.0 in region us-central1
```

**Solution:**

**Check current quota:**
```bash
gcloud compute project-info describe --project=YOUR-PROJECT-ID
```

**Request quota increase:**
1. Go to: https://console.cloud.google.com/iam-admin/quotas
2. Filter by "In-use IP addresses"
3. Click "Edit Quotas"
4. Request increase
5. Wait for approval (usually 24-48 hours)

**Temporary workaround:**
```bash
# Use different region with available quota
# Edit terraform/terraform.tfvars:
zone = "us-east1-b"  # Try different zone
```

---

## GCP/GKE Issues

### Issue: GCP project not found

**Symptoms:**
```
Error: Error setting project: googleapi: Error 403: ... does not have permission
```

**Solution:**
```bash
# List available projects
gcloud projects list

# Set correct project
gcloud config set project YOUR-CORRECT-PROJECT-ID

# Verify
gcloud config get-value project
```

---

### Issue: APIs not enabled

**Symptoms:**
```
Error: Error creating Cluster: googleapi: Error 403: Kubernetes Engine API has not been used
```

**Solution:**
```bash
# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Verify
gcloud services list --enabled
```

---

### Issue: Billing not enabled

**Symptoms:**
```
Error: The billing account for the owning project is disabled
```

**Solution:**
1. Go to: https://console.cloud.google.com/billing
2. Link a billing account to your project
3. If new user, activate $300 free credit
4. Verify billing is enabled:
```bash
gcloud beta billing projects describe YOUR-PROJECT-ID
```

---

### Issue: Node pool creation timeout

**Symptoms:**
```
Error: timeout while waiting for state to become 'RUNNING'
```

**Cause:** GCP taking longer than expected

**Solution:**
```bash
# Check cluster status
gcloud container clusters describe YOUR-CLUSTER-NAME \
  --zone=us-central1-a

# If cluster is running but terraform failed, import state:
cd terraform
terraform import google_container_cluster.security_demo_cluster YOUR-CLUSTER-NAME
terraform import google_container_node_pool.security_demo_nodes \
  YOUR-PROJECT-ID/us-central1-a/YOUR-CLUSTER-NAME/YOUR-NODE-POOL-NAME
```

---

### Issue: Cluster already exists

**Symptoms:**
```
Error: Error creating Cluster: googleapi: Error 409: Already Exists
```

**Cause:** Previous deployment wasn't cleaned up

**Solution:**

**Option 1: Import existing cluster**
```bash
cd terraform
terraform import google_container_cluster.security_demo_cluster YOUR-CLUSTER-NAME
```

**Option 2: Delete and recreate**
```bash
# Delete via gcloud
gcloud container clusters delete YOUR-CLUSTER-NAME \
  --zone=us-central1-a \
  --quiet

# Then run setup again
./scripts/mac/setup.sh
```

---

## Script Issues

### Issue: Permission denied (Mac/Linux)

**Symptoms:**
```bash
./scripts/mac/setup.sh
# Output: Permission denied
```

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/mac/*.sh

# Then run
./scripts/mac/setup.sh
```

---

### Issue: Execution policy error (Windows)

**Symptoms:**
```powershell
.\scripts\win\setup.ps1
# Output: cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run script
.\scripts\win\setup.ps1
```

---

### Issue: Script can't find terraform directory

**Symptoms:**
```bash
./scripts/mac/setup.sh
# Error: cd: terraform: No such file or directory
```

**Cause:** Running script from wrong directory

**Solution:**
```bash
# Always run from project root
cd ~/path/to/gke-kubernetes-demo

# Verify you're in right place
ls
# Should see: terraform/ scripts/ sample-apps/ docs/

# Now run script
./scripts/mac/setup.sh
```

---

### Issue: kubectl not configured after setup

**Symptoms:**
```bash
kubectl get nodes
# Error: The connection to the server localhost:8080 was refused
```

**Solution:**
```bash
# Get cluster credentials manually
gcloud container clusters get-credentials YOUR-CLUSTER-NAME \
  --zone=us-central1-a \
  --project=YOUR-PROJECT-ID

# Verify
kubectl cluster-info
kubectl get nodes
```

---

## Application Deployment Issues

### Issue: Pod stuck in Pending

**Symptoms:**
```bash
kubectl get pods
# NAME                     READY   STATUS    
# hello-kubernetes-xxx     0/1     Pending
```

**Diagnose:**
```bash
# Check pod details
kubectl describe pod POD-NAME

# Common causes in Events section:
# - Insufficient CPU/memory
# - No nodes available
# - Image pull errors
```

**Solutions:**

**Insufficient resources:**
```bash
# Check node resources
kubectl top nodes
kubectl describe nodes

# Scale deployment down
kubectl scale deployment hello-kubernetes --replicas=1

# Or add more nodes (edit terraform/terraform.tfvars)
node_count = 2
# Then: terraform apply
```

**No nodes:**
```bash
# Check if nodes exist
kubectl get nodes

# If no nodes, check GKE
gcloud container clusters describe YOUR-CLUSTER-NAME \
  --zone=us-central1-a
```

---

### Issue: Pod CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods
# NAME                     READY   STATUS
# django-demo-xxx          0/1     CrashLoopBackOff
```

**Diagnose:**
```bash
# Check logs
kubectl logs POD-NAME

# Check previous logs
kubectl logs POD-NAME --previous

# Describe pod
kubectl describe pod POD-NAME
```

**Common causes:**
- Application error (check logs)
- Missing dependencies
- Configuration error
- Resource limits too low

**Solution:**
```bash
# For Django demo (takes 2-3 min to start)
# Just wait longer, or check logs:
kubectl logs -f POD-NAME

# If actual crash, delete and recreate
kubectl delete pod POD-NAME
# Kubernetes will recreate automatically
```

---

### Issue: ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods
# NAME                     READY   STATUS
# nginx-demo-xxx           0/1     ImagePullBackOff
```

**Diagnose:**
```bash
kubectl describe pod POD-NAME
# Look for: Failed to pull image
```

**Common causes:**
- Image doesn't exist
- Private registry requires auth
- Network issues

**Solution:**
```bash
# Verify image exists
docker pull nginx:1.27.2-alpine

# Check if it's a typo in YAML
kubectl get deployment DEPLOYMENT-NAME -o yaml | grep image:

# For our demos, shouldn't happen (using public images)
# If it does, delete and reapply:
kubectl delete -f sample-apps/nginx-demo.yaml
kubectl apply -f sample-apps/nginx-demo.yaml
```

---

### Issue: LoadBalancer stuck in Pending

**Symptoms:**
```bash
kubectl get service django-demo
# NAME          TYPE           EXTERNAL-IP   PORT(S)
# django-demo   LoadBalancer   <pending>     80:30123/TCP
```

**Cause:** GCP provisioning LoadBalancer (normal, takes 2-3 minutes)

**Solution:**
```bash
# Wait and watch
kubectl get service django-demo --watch

# Check events
kubectl describe service django-demo

# If stuck for > 5 minutes:
# 1. Check GCP quotas (Load Balancers quota)
gcloud compute project-info describe

# 2. Check service configuration
kubectl get service django-demo -o yaml

# 3. Recreate service
kubectl delete service django-demo
kubectl apply -f sample-apps/django-demo.yaml
```

---

### Issue: Can't access application via external IP

**Symptoms:**
```bash
# Service has external IP
kubectl get service
# EXTERNAL-IP: 34.123.45.67

# But curl fails
curl http://34.123.45.67
# Connection refused or timeout
```

**Diagnose:**
```bash
# 1. Check if pods are running
kubectl get pods

# 2. Check if service has endpoints
kubectl get endpoints

# 3. Test from within cluster
kubectl run test --image=busybox -it --rm -- wget -O- http://SERVICE-NAME
```

**Solutions:**

**Firewall issue:**
```bash
# GKE should auto-create firewall rules
# Verify in GCP Console:
# VPC Network > Firewall > Look for k8s rules

# If missing, manually create:
gcloud compute firewall-rules create allow-k8s-lb \
  --allow tcp:80,tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags gke-YOUR-CLUSTER-NAME
```

**Wrong port:**
```bash
# Service exposes port 80
kubectl get service django-demo
# PORT(S): 80:30123/TCP

# Access via port 80, not 8000 or 30123
curl http://34.123.45.67:80
# or just
curl http://34.123.45.67
```

**Pod not ready:**
```bash
# Check readiness
kubectl get pods
# READY should be 1/1

# If 0/1, check readiness probe
kubectl describe pod POD-NAME
```

---

## Network/Connectivity Issues

### Issue: kubectl commands timeout

**Symptoms:**
```bash
kubectl get nodes
# Unable to connect to the server: dial tcp: i/o timeout
```

**Solution:**
```bash
# 1. Check if cluster is running
gcloud container clusters list

# 2. Get fresh credentials
gcloud container clusters get-credentials YOUR-CLUSTER-NAME \
  --zone=us-central1-a

# 3. Check your network
ping 8.8.8.8

# 4. Check if VPN/proxy blocking
# Temporarily disable and retry

# 5. Verify kubectl config
kubectl config view
kubectl config current-context
```

---

### Issue: Pods can't reach internet

**Symptoms:**
```bash
# Pod can't download packages or reach external APIs
kubectl logs POD-NAME
# Error: connection timeout
```

**Diagnose:**
```bash
# Test from pod
kubectl exec POD-NAME -- ping -c 3 8.8.8.8
kubectl exec POD-NAME -- nslookup google.com
```

**Solutions:**

**Check NAT Gateway (if using private nodes):**
- GKE auto-configures this for standard clusters
- For private clusters, verify Cloud NAT

**Check Network Policy:**
```bash
# List network policies
kubectl get networkpolicies

# If blocking, delete or modify
kubectl delete networkpolicy POLICY-NAME
```

---

## Cost Issues

### Issue: Unexpected high costs

**Symptoms:**
- Higher than expected GCP bill
- Budget alerts firing

**Diagnose:**
```bash
# Check what's running
gcloud container clusters list
kubectl get all --all-namespaces

# Check LoadBalancers (cost money)
kubectl get services --all-namespaces

# Check persistent volumes
kubectl get pv
```

**Solutions:**

**Delete unused resources:**
```bash
# Delete test deployments
kubectl delete -f sample-apps/

# Delete cluster when not in use
./scripts/mac/cleanup.sh
```

**Scale down for dev:**
```bash
# Edit terraform/terraform.tfvars
node_count = 1       # Reduce nodes
machine_type = "e2-small"  # Smaller machines

# Apply changes
cd terraform
terraform apply
```

**Set budget alerts:**
```bash
# In GCP Console:
# Billing > Budgets & alerts
# Set alert at $10, $20, $50
```

---

### Issue: Can't delete cluster to stop costs

**See:** [Cannot destroy cluster (deletion_protection)](#issue-cannot-destroy-cluster-deletion_protection) above

---

## Security Demo Issues

### Issue: Vulnerable app won't deploy

**Symptoms:**
```bash
kubectl apply -f sample-apps/nginx-vulnerable.yaml
# Error: pods "nginx-vulnerable-xxx" is forbidden
```

**Cause:** Pod Security Standards blocking dangerous config

**Solution:**
```bash
# Check if PSS enabled on namespace
kubectl get namespace default -o yaml | grep pod-security

# This is intentional - vulnerable app should be restricted
# To demo, use namespace without PSS:
kubectl create namespace demo
kubectl apply -f sample-apps/nginx-vulnerable.yaml -n demo
```

---

### Issue: Can't access admin panel in Django demo

**Symptoms:**
```
# Visit http://EXTERNAL-IP/admin
# Shows 404 or doesn't load
```

**Solution:**
```bash
# 1. Wait for pod to be fully ready (2-3 minutes)
kubectl get pods -l app=django-demo

# 2. Check logs
kubectl logs -l app=django-demo

# 3. Verify service
kubectl get service django-demo

# 4. Try port-forward as test
kubectl port-forward service/django-demo 8080:80
# Then visit: http://localhost:8080/admin

# 5. Login credentials
# Username: demo
# Password: demo
```

---

## General Debugging Commands

### Cluster Health
```bash
# Cluster status
gcloud container clusters describe YOUR-CLUSTER-NAME \
  --zone=us-central1-a

# Node status
kubectl get nodes
kubectl describe nodes

# All resources
kubectl get all --all-namespaces

# Events
kubectl get events --sort-by=.metadata.creationTimestamp

# Cluster info
kubectl cluster-info
kubectl cluster-info dump > cluster-dump.txt
```

### Pod Debugging
```bash
# Get pod details
kubectl get pods -o wide
kubectl describe pod POD-NAME

# Logs
kubectl logs POD-NAME
kubectl logs POD-NAME --previous
kubectl logs -f POD-NAME  # Follow logs

# Execute commands in pod
kubectl exec POD-NAME -- COMMAND
kubectl exec -it POD-NAME -- /bin/bash

# Port forward for testing
kubectl port-forward POD-NAME 8080:80
```

### Service Debugging
```bash
# Service details
kubectl get services
kubectl describe service SERVICE-NAME

# Endpoints (should match number of pods)
kubectl get endpoints

# Test service from within cluster
kubectl run test --image=busybox -it --rm -- \
  wget -O- http://SERVICE-NAME
```

### Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods

# Describe for limits
kubectl describe pod POD-NAME | grep -A 5 Limits
```

---

## Getting Help

### Check Documentation
1. Main README: `README.md`
2. Quick reference: `docs/QUICKSTART.md`
3. Security guide: `docs/SECURITY-DEMO.md`
4. Django guide: `docs/DJANGO-DEMO.md`

### Collect Information
When reporting issues, include:
```bash
# System info
uname -a  # or: systeminfo on Windows
terraform --version
gcloud --version
kubectl version

# Error output
# Copy full error message

# Configuration
cat terraform/terraform.tfvars  # Remove sensitive data!
kubectl get all
kubectl describe pod POD-NAME
```

### Common Commands for Support
```bash
# Export cluster config
kubectl config view > kubectl-config.txt

# Export resource state
kubectl get all -o yaml > resources.yaml

# Export events
kubectl get events --sort-by=.metadata.creationTimestamp > events.txt

# Export terraform state
cd terraform
terraform show > terraform-state.txt
```

---

## Quick Reference

### Most Common Issues

| Issue | Quick Fix |
|-------|-----------|
| Command not found | Install prerequisites |
| Permission denied | `chmod +x scripts/mac/*.sh` |
| No terraform.tfvars | `cp terraform.tfvars.example terraform.tfvars` |
| Not authenticated | `gcloud auth login` |
| Can't delete cluster | Add `deletion_protection = false` |
| Pod pending | Wait or check resources |
| No external IP | Wait 2-3 minutes |
| High costs | Delete cluster when not in use |

### Emergency Commands
```bash
# Stop everything quickly
./scripts/mac/cleanup.sh  # or .\scripts\win\cleanup.ps1

# Or force delete
gcloud container clusters delete YOUR-CLUSTER-NAME \
  --zone=us-central1-a \
  --quiet

# Check what's costing money
gcloud container clusters list
kubectl get services --all-namespaces
```

---

**Still having issues?** Check the main README or create an issue on GitHub with:
- Error message
- Steps to reproduce
- System information
- What you've tried

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.