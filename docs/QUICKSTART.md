# Quick Start Guide - Deploy to EKS

## Prerequisites Checklist

- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] kubectl installed
- [ ] Docker installed
- [ ] EKS cluster created and accessible
- [ ] kubectl configured for your EKS cluster (`aws eks update-kubeconfig --name <cluster-name>`)

## Quick Deployment Steps

### 1. Set Up ECR Repository

**Windows (PowerShell):**
```powershell
.\setup-ecr.ps1
```

**Linux/Mac:**
```bash
chmod +x setup-ecr.sh
./setup-ecr.sh
```

### 2. Build and Push Docker Image

**Windows (PowerShell):**
```powershell
.\build.ps1
# Or with version
.\build.ps1 -Version v1.0.0
```

**Linux/Mac:**
```bash
chmod +x build.sh
./build.sh
# Or with version
./build.sh v1.0.0
```

### 3. Update Kubernetes Manifests

**Important:** Before deploying, update the image URL in `k8s/deployment.yaml`:

Replace `<account-id>` and `<region>` with your values:
```yaml
image: <account-id>.dkr.ecr.<region>.amazonaws.com/eyegic-opticals:latest
```

**Optional:** Update domain in `k8s/ingress.yaml`:
```yaml
host: your-domain.com  # Replace eyegic.example.com
```

### 4. Deploy to EKS

**Windows (PowerShell):**
```powershell
.\deploy.ps1
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

### 5. Access Your Application

**Option A: Port Forward (Quick Test)**
```bash
kubectl port-forward -n eyegic-opticals svc/eyegic-opticals-service 8080:80
```
Then open: http://localhost:8080

**Option B: Via Ingress (Production)**
Access via your configured domain: `https://your-domain.com`

**Option C: LoadBalancer Service**
Update `k8s/service.yaml` to use `type: LoadBalancer`, then:
```bash
kubectl get svc eyegic-opticals-service -n eyegic-opticals
```

## Verify Deployment

```bash
# Check pods
kubectl get pods -n eyegic-opticals

# Check service
kubectl get svc -n eyegic-opticals

# Check deployment status
kubectl rollout status deployment/eyegic-opticals -n eyegic-opticals

# View logs
kubectl logs -f deployment/eyegic-opticals -n eyegic-opticals
```

## Troubleshooting

**Pods not starting?**
```bash
kubectl describe pod <pod-name> -n eyegic-opticals
kubectl logs <pod-name> -n eyegic-opticals
```

**Image pull errors?**
- Verify ECR repository exists
- Check IAM permissions
- Ensure image tag is correct in deployment.yaml

**Can't access the service?**
- Check if ingress controller is installed
- Verify service type and selectors
- Check ingress configuration

## Next Steps

- Set up SSL/TLS certificates (see DEPLOYMENT.md)
- Configure monitoring and logging
- Set up CI/CD pipeline
- Configure auto-scaling

For detailed information, see [DEPLOYMENT.md](DEPLOYMENT.md)
