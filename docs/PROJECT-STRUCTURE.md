# Project Structure - Complete Organization Guide

## Overview

This project follows a clean, organized folder structure that separates concerns and makes it easy to navigate.

## Directory Structure

```
├── README.md                    # Main project documentation
├── .gitignore                   # Git ignore rules
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                  # GKE cluster configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output values
│   ├── terraform.tfvars.example # Configuration template
│   ├── terraform.tfvars.minimal # Minimal cost configuration
│   └── terraform.tfvars        # Your config (gitignored)
│
├── scripts/                     # Automation scripts
│   ├── mac/                    # Mac/Linux scripts
│   │   ├── setup.sh            # Deploy cluster
│   │   ├── test-app.sh         # App deployment menu
│   │   └── cleanup.sh          # Delete cluster
│   └── win/                    # Windows scripts
│       ├── setup.ps1           # Deploy cluster
│       ├── test-app.ps1        # App deployment menu
│       └── cleanup.ps1         # Delete cluster
│
├── sample-apps/                 # Kubernetes applications
│   ├── deployment.yaml         # Hello Kubernetes app
│   ├── nginx-demo.yaml         # NGINX demo
│   ├── guestbook.yaml          # Multi-tier app
│   ├── nginx-vulnerable.yaml   # Security demo (vulnerable)
│   └── nginx-secure.yaml       # Security demo (secure)
│
└── docs/                        # Documentation
    ├── PROJECT-STRUCTURE.md    # This file
    ├── README.md               # README Setup Document
    ├── QUICKSTART.md           # Quick command reference
    ├── SETUP-SUMMARY.md        # Configuration details
    ├── SECURITY-DEMO.md        # Security walkthrough
    ├── SECURITY-QUICKREF.md    # Security commands
    └── TROUBLESHOOTING.md      # Common issues
```

## Folder Details

### 📂 terraform/
**Purpose:** Infrastructure as Code for GKE cluster

**Files:**
- `main.tf` - Core cluster configuration
- `variables.tf` - Customizable parameters
- `outputs.tf` - Values returned after deployment
- `terraform.tfvars.example` - Template for Demo
- `terraform.tfvars.minimal` - Ultra-low-cost option
- `terraform.tfvars` - Actual config (not in git)

**Usage:**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform apply
```

### 📂 scripts/
**Purpose:** Cross-platform automation scripts

**Files:**
- `setup.sh/ps1` - Automated cluster deployment
- `test-app.sh/ps1` - Interactive app deployment
- `cleanup.sh/ps1` - Cluster deletion

**Usage:**
```bash
# Mac/Linux
./scripts/mac/setup.sh
./scripts/mac/test-app.sh
./scripts/mac/cleanup.sh

# Windows
.\scripts\win\setup.ps1
.\scripts\win\test-app.ps1
.\scripts\win\cleanup.ps1
```

### 📂 sample-apps/
**Purpose:** Ready-to-deploy Kubernetes applications

**Files:**
- `deployment.yaml` - Simple Hello Kubernetes
- `nginx-demo.yaml` - NGINX web server
- `guestbook.yaml` - Multi-tier with Redis
- `nginx-vulnerable.yaml` - 16 security flaws (demo)
- `nginx-secure.yaml` - Security best practices

**Usage:**
```bash
kubectl apply -f sample-apps/deployment.yaml
kubectl apply -f sample-apps/nginx-vulnerable.yaml
kubectl apply -f sample-apps/nginx-secure.yaml
```

### 📂 docs/
**Purpose:** Comprehensive documentation

**Files:**
- `PROJECT-STRUCTURE.md` - This file
- `QUICKSTART.md` - Quick command reference
- `SETUP-SUMMARY.md` - Configuration overview
- `SECURITY-DEMO.md` - Full security walkthrough
- `SECURITY-QUICKREF.md` - Quick security tests
- `TROUBLESHOOTING.md` - Problem solutions

## File Naming Conventions

### Terraform Files
- `.tf` extension
- Lowercase with hyphens
- Descriptive names (main, variables, outputs)

### Scripts
- `.sh` for Mac/Linux (bash)
- `.ps1` for Windows (PowerShell)
- Lowercase with hyphens
- Executable permissions for .sh files

### Kubernetes Manifests
- `.yaml` extension
- Lowercase with hyphens
- Descriptive of application

### Documentation
- `.md` extension (Markdown)
- UPPERCASE for main docs
- Descriptive names

## Git Ignore Strategy

The `.gitignore` file excludes:
- `terraform/terraform.tfvars` (contains project ID)
- `terraform/.terraform/` (Terraform cache)
- `terraform/*.tfstate` (Terraform state)
- IDE and OS files

**Always commit:**
- `.example` template files
- Documentation
- Scripts
- Sample apps

**Never commit:**
- Actual `terraform.tfvars` (has secrets)
- Terraform state files
- `.terraform` directory

## Navigation Tips

### Starting Out
1. Read main `README.md` first
2. Follow setup in `scripts/mac/setup.sh`
3. Test with `scripts/mac/test-app.sh`
4. Refer to `docs/QUICKSTART.md` for commands

### For Security Demo
1. Deploy apps with `scripts/mac/test-app.sh`
2. Follow `docs/SECURITY-DEMO.md`
3. Use `docs/SECURITY-QUICKREF.md` for quick tests

### Troubleshooting
1. Check `docs/TROUBLESHOOTING.md`
2. Review error messages
3. Verify paths and permissions

## Benefits of This Structure

### ✅ Clear Separation of Concerns
- Infrastructure code in `terraform/`
- Automation in `scripts/`
- Applications in `sample-apps/`
- Documentation in `docs/`

### ✅ Easy to Navigate
- Logical folder names
- Predictable locations
- Consistent naming

### ✅ Scalable
- Add new apps to `sample-apps/`
- Add docs to `docs/`
- Keep infrastructure separate

### ✅ Git-Friendly
- Proper `.gitignore`
- No secrets in repo
- Clean commit history

### ✅ Cross-Platform
- Scripts for both OSes
- Works on Windows and Mac
- Consistent experience

## Common Tasks

### Deploy Cluster
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID
cd ..
./scripts/mac/setup.sh
```

### Test Application
```bash
./scripts/mac/test-app.sh
# Choose option 1 for Hello Kubernetes
```

### Security Demo
```bash
./scripts/mac/test-app.sh
# Choose option 4 for vulnerable app
# Choose option 5 for secure app
# Follow docs/SECURITY-DEMO.md
```

### Cleanup
```bash
./scripts/mac/cleanup.sh
```

## Best Practices

### When Working with Git
```bash
# Always check what you're committing
git status
git diff

# Never commit terraform.tfvars
git add terraform/terraform.tfvars  # ❌ DON'T DO THIS

# Commit templates instead
git add terraform/terraform.tfvars.example  # ✅ OK
```

### When Writing Scripts
- Keep scripts in `scripts/` (mac/win)folder
- Use relative paths from script location
- Support both Windows and Mac
- Add comments and error handling

### When Adding Apps
- Keep manifests in `sample-apps/`
- Optimize for single-node cluster
- Document resource requirements
- Test before committing

### When Writing Docs
- Place in `docs/` folder
- Use clear section headers
- Include examples
- Link related documents

## Quick Reference

| Task | Command |
|------|---------|
| Setup cluster | `./scripts/mac/setup.sh` |
| Deploy app | `./scripts/mac/test-app.sh` |
| Delete cluster | `./scripts/mac/cleanup.sh` |
| View structure | `tree -L 2` (if tree installed) |
| Navigate to terraform | `cd terraform` |
| Navigate to docs | `cd docs` |
| Apply terraform | `cd terraform && terraform apply` |
| Deploy specific app | `kubectl apply -f sample-apps/deployment.yaml` |

## Troubleshooting Paths

### "terraform.tfvars not found"
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

### "Script not found"
```bash
# Make sure you're in project root
pwd  # Should show .../gke-security-demo

# Scripts are in scripts/ (mac/win)folder
ls scripts/  # Should show setup.sh, etc.

# Run from project root
./scripts/mac/setup.sh
```

### "kubectl apply failed"
```bash
# Make sure path is correct
kubectl apply -f sample-apps/deployment.yaml

# Not:
kubectl apply -f sample-app/deployment.yaml  # Wrong!
```

## Summary

This organized structure makes it easy to:
- ✅ Find what you need quickly
- ✅ Understand project organization
- ✅ Add new features cleanly
- ✅ Maintain the project long-term
- ✅ Learn effectively

**Everything has its place, and there's a place for everything!** 🎯

**Documentation by SecuredPress**

*Part of the GKE Kubernetes Security Demo Project*

© 2024 SecuredPress LLC. Licensed under MIT.