# GKE Basic Kubernetes Cluster Setup for Security Demo

> Created by SecuredPress LLC | Jose Perez
> AI and CyberSecurity Training

This repository contains everything you need to automatically deploy a Kubernetes cluster on Google Cloud Platform (GCP) using Terraform.

## Prerequisites

Before you begin, you need to install the following tools on your computer:

### 1. Google Cloud SDK (gcloud)

**Windows:**
- Download from: https://cloud.google.com/sdk/docs/install
- Run the installer and follow the prompts
- Restart your terminal after installation

**Mac:**
```bash
# Using Homebrew
brew install --cask google-cloud-sdk
```

**Verify installation:**
```bash
gcloud --version
```

### 2. Terraform

**Windows:**
- Download from: https://www.terraform.io/downloads
- Extract the zip file
- Add the terraform.exe location to your PATH environment variable

Or use Chocolatey:
```powershell
choco install terraform
```

**Mac:**
```bash
# Using Homebrew
brew install terraform
```

**Verify installation:**
```bash
terraform --version
```

### 3. kubectl (Kubernetes CLI)

**Windows:**
```powershell
gcloud components install kubectl
```

**Mac:**
```bash
gcloud components install kubectl
# Or via Homebrew
brew install kubectl
```

### 4. GKE authentication plugin (for kubectl)

**Windows:**
```powershell
gcloud components install gke-gcloud-auth-plugin
```

**Mac:**
```bash
gcloud components install gke-gcloud-auth-plugin
# Or via Homebrew
brew install gke-gcloud-auth-plugin
```

**Verify installation:**
```bash
gke-gcloud-auth-plugin --version
```

## Google Cloud Setup

### 1. Create a GCP Project

1. Go to https://console.cloud.google.com/
2. Click "Select a Project" → "New Project"
3. Give your project a name (e.g., "k8s-security-demo")
4. Note your **Project ID** (you'll need this!)

### 2. Enable Billing

1. In the GCP Console, go to "Billing"
2. Link a billing account to your project
3. **Note:** Google offers $300 in free credits for new users!

### 3. Get Your Project ID

You can find your project ID in the GCP Console dashboard or by running:
```bash
gcloud projects list
```

## Deployment Steps

### Step 1: Configure Your Project

1. Copy the example configuration file:
   ```bash
   # Mac/Linux
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   
   # Windows
   cd terraform
   copy terraform.tfvars.example terraform.tfvars
   
   # OR for the cheapest single-node setup:
   # cp terraform.tfvars.minimal terraform.tfvars
   ```

2. Edit `terraform/terraform.tfvars` and replace `YOUR-GCP-PROJECT-ID` with your actual project ID:
   ```hcl
   project_id   = "your-actual-project-id"
   cluster_name = "my-demo-cluster"
   
   # Default is already single-node, but you can verify:
   node_count   = 1
   machine_type = "e2-small"  # Cheapest option
   ```

**Configuration Options:**
- **terraform.tfvars.example** - Standard single-node setup (recommended)
- **terraform.tfvars.minimal** - Locked to 1 node, no autoscaling (cheapest)

### Step 2: Run the Setup Script

**Mac/Linux:**
```bash
chmod +x scripts/setup.sh
./scripts/mac/setup.sh
```

**Windows (PowerShell as Administrator):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\win\setup.ps1
```

The script will:
- Check that all prerequisites are installed
- Authenticate you with Google Cloud
- Enable required APIs
- Create your Kubernetes cluster
- Configure kubectl to connect to your cluster

**This process takes about 5-10 minutes.**

### Step 3: Verify Your Cluster

Once the setup is complete, verify your cluster is running:

```bash
# Check cluster nodes
kubectl get nodes

# Check system pods
kubectl get pods -A

# Check cluster info
kubectl cluster-info
```

## Testing Your Cluster with Sample Applications

We've included three sample applications you can deploy to test your cluster!

### Quick Start - Deploy Sample Apps

**Mac/Linux:**
```bash
chmod +x scripts/mac/test-app.sh
./scripts/mac/test-app.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\win\test-app.ps1
```

The test script provides an interactive menu with these options:

### Sample Applications Included:

#### 1. Hello Kubernetes (Recommended First Test)
- **What it does:** Simple web application that displays a welcome message
- **Components:** 1 replica of a web server
- **Perfect for:** Verifying your cluster works and understanding basic deployments
- **Access:** The script will automatically show you the URL

#### 2. NGINX Demo
- **What it does:** Deploys the NGINX web server
- **Components:** 1 NGINX pod with resource limits
- **Perfect for:** Learning about resource management and basic services
- **Access:** Get IP with `kubectl get service nginx-service`

#### 3. Guestbook (Advanced)
- **What it does:** Multi-tier application with a web frontend and Redis database
- **Components:** 
  - Frontend (1 replica)
  - Redis master (1 replica)
  - Redis replicas (1 replica)
- **Perfect for:** Understanding multi-tier applications and service communication
- **Access:** Get IP with `kubectl get service guestbook`

#### 4. NGINX Vulnerable (Security Demo) ⚠️
- **What it does:** Intentionally insecure deployment for security education
- **Contains:** 16 common security vulnerabilities
- **Perfect for:** Learning what NOT to do and understanding security risks
- **⚠️ WARNING:** For educational use only, do NOT expose to internet!
- **Documentation:** See `SECURITY-DEMO.md` for full details

#### 5. NGINX Secure (Security Demo) ✅
- **What it does:** Properly secured deployment showing best practices
- **Features:** All security controls properly implemented
- **Perfect for:** Learning security best practices
- **Compare with:** NGINX Vulnerable to see the differences
- **Documentation:** See `SECURITY-DEMO.md` for comparison

### Manual Deployment (Alternative)

If you prefer to deploy manually:

```bash
# Deploy Hello Kubernetes
kubectl apply -f sample-apps/deployment.yaml

# Check the deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Get the external IP (wait a minute for LoadBalancer)
kubectl get service hello-kubernetes

# Access the app at: http://EXTERNAL-IP
```

### Viewing Your Application

Once deployed, you can:

```bash
# Check if pods are running
kubectl get pods

# View logs from a pod
kubectl logs <pod-name>

# Get service details and external IP
kubectl get service <service-name>

# Describe a service for more details
kubectl describe service <service-name>

# Watch pods in real-time
kubectl get pods --watch
```

### Cleaning Up Sample Apps

Use the test script (option 8) or manually:

```bash
# Delete specific app
kubectl delete -f sample-apps/deployment.yaml

# Delete all sample apps
kubectl delete -f sample-apps/
```

## Important: Cost Management

**⚠️ IMPORTANT:** GKE clusters cost money! To avoid unexpected charges:

1. **Delete your cluster when not in use** (see cleanup below)
2. Monitor your costs in the GCP Console
3. Set up billing alerts
4. This setup uses a **single-node cluster** for minimal cost

### Cost Breakdown (Approximate Monthly)

**Default Configuration (1 node):**
- 1 x e2-small node: **~$12-15/month**
- GKE management fee: **FREE** (for single Autopilot or 1-zone cluster)
- **Total: ~$12-15/month** or **~$0.40-0.50/day**

**If You Scale Up:**
- 3 x e2-small nodes: ~$36-45/month
- 3 x e2-medium nodes: ~$75-100/month

### Cost-Saving Tips:
```bash
# Option 1: Delete cluster when done (RECOMMENDED)
./scripts/mac/cleanup.sh  # or .\scripts\cleanup.ps1

# Option 2: Scale to zero nodes when not in use
gcloud container clusters resize my-demo-cluster --num-nodes=0 --zone=us-central1-a

# Scale back up when needed
gcloud container clusters resize my-demo-cluster --num-nodes=1 --zone=us-central1-a
```

**💡 Best Practice for Demo:** Delete the cluster after each demo and recreate it when needed. Setup takes ~10 minutes but saves significant costs!

## Cleanup (Deleting Your Cluster)

When you're done with your cluster, **always delete it** to stop charges:

**Mac/Linux:**
```bash
chmod +x scripts/mac/cleanup.sh
./scripts/mac/cleanup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\win\cleanup.ps1
```

This will destroy all resources and stop billing.

## Configuration Options

You can customize your cluster by editing `terraform/terraform.tfvars`:

```hcl
cluster_name = "my-cluster"      # Your cluster name
node_count   = 1                 # Number of nodes (default: 1)
min_nodes    = 1                 # Minimum nodes (autoscaling)
max_nodes    = 3                 # Maximum nodes (autoscaling)
machine_type = "e2-small"        # Machine type
zone         = "us-central1-a"   # GCP zone
```

After changing values, run the setup script again or use:
```bash
cd terraform
terraform apply
```

## Troubleshooting

### "gcloud: command not found"
- Make sure Google Cloud SDK is installed and in your PATH
- Restart your terminal after installation

### "Permission denied" on Mac/Linux
- Make scripts executable: `chmod +x setup.sh cleanup.sh`

### "API not enabled" errors
- The setup script should enable APIs automatically
- If not, manually enable in GCP Console: Container API and Compute API

### "Project ID not found"
- Verify your project ID is correct
- Make sure you've set up billing for the project

### Authentication Issues
- Run `gcloud auth login` to re-authenticate
- Run `gcloud auth application-default login` for Terraform

## Useful Commands

```bash
# View cluster info
kubectl cluster-info
gcloud container clusters describe my-demo-cluster --zone=us-central1-a

# View Terraform state
terraform show

# Update cluster configuration
terraform apply

# View costs in real-time
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID

# Stop/start cluster (to save costs when not in use)
gcloud container clusters resize my-demo-cluster --num-nodes=0 --zone=us-central1-a
gcloud container clusters resize my-demo-cluster --num-nodes=3 --zone=us-central1-a
```

## Getting Help

- **Google Cloud Documentation:** https://cloud.google.com/kubernetes-engine/docs
- **Kubernetes Documentation:** https://kubernetes.io/docs/
- **Terraform GCP Provider:** https://registry.terraform.io/providers/hashicorp/google/latest/docs

## Important Notes

- **Never commit `terraform.tfvars`** to version control (it contains your project ID)
- **Always clean up resources** when finished to avoid charges
- The default configuration includes autoscaling (1-5 nodes)
- Auto-repair and auto-upgrade are enabled for easier maintenance

---

## 👨‍💻 Author

**Jose Perez**
- Company: SecuredPress LLC
- Website: securedpress.com
- GitHub: https://github.com/securedpress

## 📄 License

MIT License - Copyright (c) 2024 SecuredPress LLC

See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by SecuredPress**

## ⚖️ Copyright Notice

© 2024 SecuredPress LLC. All rights reserved.

This project is licensed under the MIT License. While the code is open source, 
the SecuredPress brand, logo, and trademarks are proprietary.

### What You Can Do:
✅ Use, modify, and distribute the code
✅ Use for commercial purposes
✅ Contribute improvements

### What You Should Not Do:
❌ Remove copyright notices
❌ Use company branding without permission
❌ Claim this as your own original work

**Attribution Required**: When using this project, please maintain the original 
copyright notices and provide a link back to this repository.