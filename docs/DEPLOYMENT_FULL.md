# Complete Deployment Guide - Eyegic Opticals

This guide covers deploying the full-stack application with frontend, backend, and database.

## Architecture Overview

```
Internet
   ↓
Ingress Controller (ALB)
   ↓
Frontend (EKS - Public Subnet) → Backend API (EKS - Private Subnet) → RDS PostgreSQL (Private Subnet)
```

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl installed
- Docker installed
- EKS cluster created (via Terraform)

## Step 1: Provision Infrastructure

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

Wait for infrastructure to be created (~15-20 minutes).

## Step 2: Configure kubectl

```bash
aws eks update-kubeconfig --name eyegic-opticals-cluster --region us-east-1
kubectl get nodes  # Verify connection
```

## Step 3: Get Infrastructure Outputs

```bash
cd infrastructure
terraform output
```

Note down:
- RDS endpoint
- ECR repository URLs
- Cluster name

## Step 4: Create Database Secret

```bash
# Get RDS endpoint from Terraform output
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Create secret (replace YOUR_DB_PASSWORD with actual password)
kubectl create secret generic eyegic-db-secret \
  --from-literal=db-host=$RDS_ENDPOINT \
  --from-literal=db-name=eyegicdb \
  --from-literal=db-user=eyegicadmin \
  --from-literal=db-password=YOUR_DB_PASSWORD \
  -n eyegic-opticals \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Step 5: Build and Push Docker Images

### Backend

```bash
cd backend

# Get ECR repository URL
ECR_URL=$(cd ../infrastructure && terraform output -raw backend_ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build image
docker build -t eyegic-backend:latest .

# Tag and push
docker tag eyegic-backend:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### Frontend

```bash
cd ..

# Get ECR repository URL
ECR_URL=$(cd infrastructure && terraform output -raw frontend_ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build image
docker build -t eyegic-frontend:latest .

# Tag and push
docker tag eyegic-frontend:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

## Step 6: Update Kubernetes Manifests

### Update Image URLs

Update `k8s/backend-deployment.yaml`:
```yaml
image: <your-ecr-url>/eyegic-opticals-backend:latest
```

Update `k8s/deployment.yaml`:
```yaml
image: <your-ecr-url>/eyegic-opticals-frontend:latest
```

### Update Database Secret

Ensure `k8s/db-secret.yaml` has correct values, or use the secret created in Step 4.

## Step 7: Deploy to Kubernetes

### Create Namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

### Deploy Database Secret

```bash
kubectl apply -f k8s/db-secret.yaml
# Or use the secret created in Step 4
```

### Deploy Backend

```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
```

### Deploy Frontend

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Deploy Ingress (Optional)

```bash
# First, install NGINX Ingress Controller if not installed
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml

# Update ingress.yaml with your domain
kubectl apply -f k8s/ingress.yaml
```

## Step 8: Verify Deployment

### Check Pods

```bash
kubectl get pods -n eyegic-opticals
```

All pods should be in `Running` state.

### Check Services

```bash
kubectl get svc -n eyegic-opticals
```

### Check Backend Logs

```bash
kubectl logs -f deployment/eyegic-backend -n eyegic-opticals
```

### Test Backend API

```bash
# Port forward to backend
kubectl port-forward -n eyegic-opticals svc/eyegic-backend-service 3000:80

# In another terminal, test API
curl http://localhost:3000/health
curl http://localhost:3000/api/enquiries
```

### Test Frontend

```bash
# Port forward to frontend
kubectl port-forward -n eyegic-opticals svc/eyegic-opticals-service 8080:80

# Open http://localhost:8080 in browser
```

## Step 9: Access Application

### Via Ingress (Production)

If ingress is configured:
- Frontend: `https://your-domain.com`
- Backend API: `https://your-domain.com/api`

### Via Port Forward (Testing)

```bash
# Frontend
kubectl port-forward -n eyegic-opticals svc/eyegic-opticals-service 8080:80

# Backend
kubectl port-forward -n eyegic-opticals svc/eyegic-backend-service 3000:80
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n eyegic-opticals

# Check logs
kubectl logs <pod-name> -n eyegic-opticals
```

### Backend Can't Connect to Database

1. Verify RDS endpoint is correct:
```bash
kubectl get secret eyegic-db-secret -n eyegic-opticals -o jsonpath='{.data.db-host}' | base64 -d
```

2. Check security group allows traffic from EKS
3. Verify database credentials

### Frontend Can't Reach Backend

1. Verify backend service exists:
```bash
kubectl get svc eyegic-backend-service -n eyegic-opticals
```

2. Check API_BASE_URL in frontend deployment
3. Test backend directly:
```bash
kubectl exec -it <frontend-pod> -n eyegic-opticals -- curl http://eyegic-backend-service/api/health
```

### Image Pull Errors

1. Verify ECR repository exists
2. Check IAM permissions for ECR
3. Verify image tag is correct
4. Check node group IAM role has ECR permissions

## Updating Application

### Update Backend

```bash
cd backend
# Make changes, then rebuild and push
docker build -t eyegic-backend:latest .
docker tag eyegic-backend:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Restart deployment
kubectl rollout restart deployment/eyegic-backend -n eyegic-opticals
```

### Update Frontend

```bash
# Make changes, then rebuild and push
docker build -t eyegic-frontend:latest .
docker tag eyegic-frontend:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Restart deployment
kubectl rollout restart deployment/eyegic-opticals -n eyegic-opticals
```

## Scaling

### Scale Backend

```bash
kubectl scale deployment eyegic-backend --replicas=3 -n eyegic-opticals
```

### Scale Frontend

```bash
kubectl scale deployment eyegic-opticals --replicas=3 -n eyegic-opticals
```

## Monitoring

### View Logs

```bash
# Backend logs
kubectl logs -f deployment/eyegic-backend -n eyegic-opticals

# Frontend logs
kubectl logs -f deployment/eyegic-opticals -n eyegic-opticals
```

### Resource Usage

```bash
kubectl top pods -n eyegic-opticals
kubectl top nodes
```

## Cleanup

To remove everything:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/ -n eyegic-opticals
kubectl delete namespace eyegic-opticals

# Destroy infrastructure
cd infrastructure
terraform destroy
```

## Cost Optimization

- Use Spot instances for node groups (save ~70%)
- Use Fargate instead of EC2 nodes
- Use smaller RDS instance for development
- Consider using S3 + CloudFront for frontend (much cheaper)

See `COST_ANALYSIS.md` for detailed cost breakdown.
