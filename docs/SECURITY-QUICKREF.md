# Security Demo - Quick Reference Card

## Deploy Applications

```bash
# Deploy vulnerable version
kubectl apply -f sample-app/nginx-vulnerable.yaml

# Deploy secure version
kubectl apply -f sample-app/nginx-secure.yaml

# Get external IPs
kubectl get services | grep nginx
```

## Quick Vulnerability Tests

### 1. Check if Running as Root
```bash
# Vulnerable (should show "root")
kubectl exec deployment/nginx-vulnerable -- whoami

# Secure (should show "nginx")
kubectl exec deployment/nginx-secure -- whoami
```

### 2. Check Version Disclosure
```bash
# Get IPs first
VULN_IP=$(kubectl get svc nginx-vulnerable -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SEC_IP=$(kubectl get svc nginx-secure -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Vulnerable (shows version)
curl -I http://$VULN_IP | grep Server

# Secure (hides version)
curl -I http://$SEC_IP | grep Server
```

### 3. Check Exposed Endpoints
```bash
# Vulnerable (shows internal stats)
curl http://$VULN_IP/server-status

# Secure (returns 404)
curl http://$SEC_IP/server-status
```

### 4. Check Resource Limits
```bash
# Vulnerable (shows <none>)
kubectl describe pod -l app=nginx-vulnerable | grep -A 5 Limits

# Secure (shows configured limits)
kubectl describe pod -l app=nginx-secure | grep -A 5 Limits
```

### 5. Check Security Context
```bash
# Vulnerable (privileged: true, runAsUser: 0)
kubectl get pod -l app=nginx-vulnerable -o yaml | grep -A 10 securityContext

# Secure (privileged: false, runAsUser: 101)
kubectl get pod -l app=nginx-secure -o yaml | grep -A 10 securityContext
```

### 6. Check for Hardcoded Secrets
```bash
# Vulnerable (shows passwords in plain text)
kubectl exec deployment/nginx-vulnerable -- env | grep -E "PASSWORD|KEY|TOKEN"

# Secure (no hardcoded secrets)
kubectl exec deployment/nginx-secure -- env | grep -E "PASSWORD|KEY|TOKEN"
```

### 7. Check Capabilities
```bash
# Vulnerable (shows ALL capabilities)
kubectl exec deployment/nginx-vulnerable -- capsh --print | grep Current

# Secure (minimal capabilities)
kubectl exec deployment/nginx-secure -- capsh --print | grep Current
```

### 8. Check Health Probes
```bash
# Vulnerable (no probes)
kubectl describe pod -l app=nginx-vulnerable | grep -E "Liveness|Readiness"

# Secure (has both probes)
kubectl describe pod -l app=nginx-secure | grep -E "Liveness|Readiness"
```

---

## Side-by-Side Comparison

### Quick Visual Test
```bash
# Open both in browser
echo "Vulnerable: http://$VULN_IP"
echo "Secure: http://$SEC_IP"

# The vulnerable page shows security issues in red
# The secure page shows security features in green
```

### Compare YAML Files
```bash
# See the differences
diff sample-app/nginx-vulnerable.yaml sample-app/nginx-secure.yaml
```

---

## Attack Simulation (Safe in Lab)

### Attempt Container Escape (Vulnerable Only)
```bash
# Get shell in vulnerable pod
POD=$(kubectl get pod -l app=nginx-vulnerable -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- /bin/bash

# Inside the container:
whoami  # root ❌
capsh --print  # ALL capabilities ❌
ls /dev  # Can see all host devices ❌

# Exit
exit
```

### Attempt in Secure Pod (Should Fail)
```bash
# Get shell in secure pod
POD=$(kubectl get pod -l app=nginx-secure -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- /bin/sh

# Inside the container:
whoami  # nginx ✅
capsh --print  # Minimal capabilities ✅
ls /dev  # Limited devices ✅

# Try to escalate (will fail)
su -  # Permission denied ✅

# Exit
exit
```

---

## Scanning Tools

### Using trivy (Image Scanning)
```bash
# Install trivy
brew install trivy  # Mac
# or
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Scan vulnerable image (old version)
trivy image nginx:1.14
# Shows many CVEs ❌

# Scan secure image (current version)
trivy image nginx:1.27.2-alpine
# Shows fewer/no CVEs ✅
```

### Using kubesec (YAML Analysis)
```bash
# Install kubesec
wget https://github.com/controlplaneio/kubesec/releases/download/v2.13.0/kubesec_linux_amd64.tar.gz
tar -xvf kubesec_linux_amd64.tar.gz

# Scan vulnerable deployment
kubesec scan sample-app/nginx-vulnerable.yaml
# Low score, many critical issues ❌

# Scan secure deployment
kubesec scan sample-app/nginx-secure.yaml
# High score, passes all checks ✅
```

### Using kube-bench (Node Security)
```bash
# Run kube-bench on the cluster
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# Check results
kubectl logs job/kube-bench

# Look for [PASS], [WARN], [FAIL] items
```

---

## Common Issues to Demonstrate

### Issue 1: Credential Theft
```bash
# Show hardcoded credentials in vulnerable pod
kubectl exec deployment/nginx-vulnerable -- env
# Output shows ADMIN_PASSWORD, API_KEY, DATABASE_URL ❌

# Show secure pod has no hardcoded secrets
kubectl exec deployment/nginx-secure -- env
# No sensitive data ✅
```

### Issue 2: Version Information Leak
```bash
# Vulnerable reveals version
curl -I http://$VULN_IP
# Server: nginx/1.14.0 ❌ (attacker can look up CVEs)

# Secure hides version
curl -I http://$SEC_IP
# Server: nginx ✅ (no version info)
```

### Issue 3: Missing Security Headers
```bash
# Vulnerable missing headers
curl -I http://$VULN_IP | grep -E "X-Frame-Options|Content-Security-Policy"
# Nothing ❌

# Secure has headers
curl -I http://$SEC_IP | grep -E "X-Frame-Options|Content-Security-Policy"
# Multiple security headers ✅
```

### Issue 4: No Rate Limiting
```bash
# Test rate limiting on vulnerable
for i in {1..100}; do curl -s -o /dev/null -w "%{http_code}\n" http://$VULN_IP; done
# All return 200 ❌ (no rate limit)

# Test rate limiting on secure
for i in {1..100}; do curl -s -o /dev/null -w "%{http_code}\n" http://$SEC_IP; done
# Some return 429 Too Many Requests ✅ (rate limited)
```

---

## Cleanup

```bash
# Remove vulnerable app
kubectl delete -f sample-app/nginx-vulnerable.yaml

# Remove secure app
kubectl delete -f sample-app/nginx-secure.yaml

# Verify cleanup
kubectl get all | grep nginx
```

---

## Exercise Checklist

You should be able to:
- [ ] Deploy both applications
- [ ] Identify all 16 vulnerabilities in the vulnerable version
- [ ] Verify security controls in the secure version
- [ ] Explain why each vulnerability is dangerous
- [ ] Use kubectl to inspect security contexts
- [ ] Test with curl to verify headers
- [ ] Use scanning tools (trivy, kubesec)
- [ ] Understand the difference between ConfigMap and Secret
- [ ] Know when to use privileged mode (almost never)
- [ ] Implement security best practices in their own apps

---

## Top 5 Security Rules

1. **Never run as root** - Use runAsUser: 1000+ (non-root)
2. **Set resource limits** - Prevent DoS attacks
3. **Use specific image versions** - Not :latest
4. **Drop all capabilities** - Use least privilege
5. **No privileged mode** - Unless absolutely necessary (rare)

---

## Emergency Response

If vulnerable app is accidentally exposed:

```bash
# Immediately delete it
kubectl delete -f sample-app/nginx-vulnerable.yaml

# Check for any suspicious activity
kubectl get events --sort-by=.metadata.creationTimestamp

# Check audit logs (if enabled)
gcloud logging read "resource.type=k8s_cluster" --limit 100

# Rotate any exposed credentials
# Review access logs
```

---

## Additional Commands

### Check Pod Security Standards
```bash
# Create namespace with restricted policy
kubectl create namespace secure-test
kubectl label namespace secure-test \
  pod-security.kubernetes.io/enforce=restricted

# Try to deploy vulnerable app (will fail)
kubectl apply -f sample-app/nginx-vulnerable.yaml -n secure-test
# Error: violates PodSecurity ✅

# Deploy secure app (will succeed)
kubectl apply -f sample-app/nginx-secure.yaml -n secure-test
# Success ✅
```

### Network Policy Example
```bash
# Create network policy to restrict traffic
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-netpol
spec:
  podSelector:
    matchLabels:
      app: nginx-secure
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 8080
EOF

# Now only pods with label access=allowed can connect
```

### RBAC Example
```bash
# Create restricted service account
kubectl create serviceaccount limited-sa

# Create role with minimal permissions
kubectl create role pod-reader \
  --verb=get,list \
  --resource=pods

# Bind role to service account
kubectl create rolebinding read-pods \
  --role=pod-reader \
  --serviceaccount=default:limited-sa

# Use in deployment
kubectl set serviceaccount deployment/nginx-secure limited-sa
```

---

## Documentation Links

- **Full Demo Guide:** See `SECURITY-DEMO.md`
- **Kubernetes Security:** https://kubernetes.io/docs/concepts/security/
- **Pod Security Standards:** https://kubernetes.io/docs/concepts/security/pod-security-standards/
- **OWASP K8s Top 10:** https://owasp.org/www-project-kubernetes-top-ten/

---

## Quick Stats

**Vulnerable App Issues:**
- 16 security vulnerabilities
- Security Score: 0/100
- CVEs: 50+ in nginx:1.14
- Risk Level: CRITICAL

**Secure App Features:**
- All security controls implemented
- Security Score: 90+/100
- CVEs: 0-2 in nginx:1.27.2-alpine
- Risk Level: LOW

---

**Remember:** Security is not a feature, it's a requirement!

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.