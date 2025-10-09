# Setup Summary - Single Node Kubernetes Cluster

## What This Creates

This Terraform setup creates a **minimal, cost-effective, single-node Kubernetes cluster** on Google Cloud Platform.

## Cluster Specifications

### Default Configuration
- **Nodes:** 1 single node (can scale to 3 if needed)
- **Machine Type:** e2-small (2 vCPU, 2GB RAM)
- **Zone:** us-central1-a
- **Autoscaling:** Enabled (min: 1, max: 3)
- **Cost:** ~$12-15/month (~$0.40-0.50/day)

### What Makes This "Simple"

1. **Single Node by Default**
   - Starts with just 1 node
   - Perfect for learning and testing
   - Can scale up if needed

2. **Small Machine Size**
   - e2-small is the smallest practical size
   - Enough for sample apps and learning
   - Minimal cost

3. **Automatic Management**
   - Auto-repair enabled (fixes broken nodes)
   - Auto-upgrade enabled (keeps Kubernetes updated)
   - Managed control plane (Google handles master nodes)

## What Can Run on This Setup?

### ✅ Works Well
- Single replica deployments
- Small web applications
- Learning Kubernetes concepts
- Testing configurations
- All included sample apps

### ⚠️ Limited
- Multiple high-replica deployments
- Resource-intensive applications
- Production workloads
- Heavy database operations

### ❌ Won't Work
- Applications requiring more than ~1.5GB RAM
- Workloads needing guaranteed high availability
- Large-scale data processing

## Cost Comparison

| Configuration | Nodes | Type | Monthly Cost |
|--------------|-------|------|--------------|
| **This Setup (Default)** | 1 | e2-small | **~$12-15** |
| With autoscaling (scaled to 3) | 3 | e2-small | ~$36-45 |
| Medium setup | 1 | e2-medium | ~$25-30 |
| Medium multi-node | 3 | e2-medium | ~$75-100 |
| Standard setup | 3 | e2-standard-2 | ~$150-180 |

## How Sample Apps Are Configured

All sample applications have been optimized for single-node clusters:

### Hello Kubernetes
- **Replicas:** 1 (instead of 3)
- **Resources:** 64Mi RAM, 100m CPU
- **Purpose:** Quick verification that cluster works

### NGINX Demo
- **Replicas:** 1 (instead of 2)
- **Resources:** 64Mi RAM, 100m CPU
- **Purpose:** Learn about basic deployments

### Guestbook (Multi-tier)
- **Frontend:** 1 replica (instead of 3)
- **Redis Master:** 1 replica
- **Redis Replica:** 1 replica (instead of 2)
- **Resources:** 50Mi RAM each, 50m CPU
- **Purpose:** Understand multi-tier applications

**Note:** All apps can be scaled up if you add more nodes or use a larger machine type.

## When to Scale Up

You might want to scale up if:

1. **You need high availability** (multiple replicas)
2. **Apps are running out of memory** (OOMKilled errors)
3. **CPU is maxed out** (check with `kubectl top nodes`)
4. **Learning about scaling and load balancing**

### How to Scale Up

**Option 1: Add more nodes**
```hcl
# Edit terraform.tfvars
node_count = 3
```

**Option 2: Use larger machines**
```hcl
# Edit terraform.tfvars
machine_type = "e2-medium"  # 4GB RAM instead of 2GB
```

Then run:
```bash
terraform apply
```

## Network & Security

### What's Included
- ✅ Default VPC and subnet
- ✅ Automatic firewall rules for LoadBalancers
- ✅ Workload Identity (secure service account access)
- ✅ Auto-repair and auto-upgrade
- ✅ TLS for cluster communication

### What's NOT Included (Keep It Simple)
- ❌ Custom VPC
- ❌ Private cluster (requires VPN/bastion)
- ❌ Binary Authorization
- ❌ Network policies
- ❌ Service Mesh

## Comparison: This Setup vs Alternatives

### This Setup (GKE Standard with Terraform)
**Pros:**
- ✅ Full Kubernetes experience
- ✅ Infrastructure as Code (repeatable)
- ✅ Learning industry-standard tools
- ✅ Can scale when needed
- ✅ Low cost

**Cons:**
- ⚠️ Requires more setup steps
- ⚠️ You'll need GCP account

### Alternatives

#### GKE Autopilot
**Pros:** Even simpler, pay-per-pod pricing
**Cons:** More expensive for always-on clusters, less control

#### Minikube/Kind (Local)
**Pros:** Free, runs on laptop
**Cons:** Not real cloud, limited to local machine, no LoadBalancer support

#### Cloud Shell + Autopilot
**Pros:** No local installation needed
**Cons:** Limited session time, costs money, temporary

## Best Practices

### Cost Management
1. **Always delete after demo**
   ```bash
   ./cleanup.sh  # or .\cleanup.ps1
   ```

2. **Monitor your spending**
   - Set up billing alerts in GCP Console
   - Check billing daily at first

3. **Use free tier credits**
   - Google offers $300 in credits for new accounts
   - This setup costs ~$0.50/day = 600 days of free usage!

### When You're Done
**ALWAYS run cleanup:**
```bash
./cleanup.sh  # Mac/Linux
.\cleanup.ps1  # Windows
```

## FAQ

**Q: Is this really a single node or will Kubernetes need multiple nodes?**
A: This is truly a single worker node. GKE manages the control plane (master) for you, so you don't pay for or see those nodes. You only have 1 worker node running your applications.

**Q: Can I run all sample apps at once on 1 node?**
A: Yes! They're optimized to use minimal resources. You can run all 3 simultaneously.

**Q: What if I get "Insufficient CPU" or memory errors?**
A: Scale up to e2-medium or add more nodes. Edit `terraform.tfvars` and run `terraform apply`.

**Q: Can I use this for a project/demo?**
A: Yes, for learning projects. For anything serious, scale up the resources.

**Q: How do I make it even cheaper?**
A: Delete the cluster when not in use. Setup only takes ~10 minutes, so recreate as needed.

**Q: Is this production-ready?**
A: No. This is for learning. Production needs multiple nodes, backups, monitoring, etc.

---

## Summary

✅ **Simple:** Single node, automatic management  
✅ **Cost-Effective:** ~$12-15/month (~$0.40-0.50/day)  
✅ **Educational:** Perfect for learning Kubernetes and applying security principles
✅ **Scalable:** Can grow when you need more  
✅ **Disposable:** Easy to delete and recreate  

This setup gives you a **real Kubernetes cluster** on **real cloud infrastructure** at the **lowest reasonable cost** for learning purposes.

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.