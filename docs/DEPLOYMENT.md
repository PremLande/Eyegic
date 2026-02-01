# Deployment Guide for Eyegic Opticals on EKS

This guide will help you deploy the Eyegic Opticals static website to an Amazon EKS (Elastic Kubernetes Service) cluster.

## Prerequisites

1. **AWS CLI** installed and configured
2. **kubectl** installed
3. **Docker** installed
4. **EKS Cluster** already created and configured
5. **kubectl** configured to connect to your EKS cluster
6. **AWS IAM permissions** for ECR and EKS

## Step 1: Set Up ECR Repository

First, create an Amazon ECR (Elastic Container Registry) repository to store your Docker images:

```bash
chmod +x setup-ecr.sh
./setup-ecr.sh
```

This script will:
- Create an ECR repository named `eyegic-opticals`
- Configure the `build.sh` script with your ECR registry URL

**Manual Setup:**
If you prefer to set up ECR manually:

```bash
aws ecr create-repository \
    --repository-name eyegic-opticals \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true
```

## Step 2: Build and Push Docker Image

Build the Docker image and push it to ECR:

```bash
chmod +x build.sh
./build.sh
```

Or specify a version:

```bash
./build.sh v1.0.0
```

**Manual Build:**
```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t eyegic-opticals:latest .

# Tag image
docker tag eyegic-opticals:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/eyegic-opticals:latest

# Push image
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/eyegic-opticals:latest
```

## Step 3: Update Kubernetes Manifests

### Update Deployment Image

Before deploying, update `k8s/deployment.yaml` with your ECR image URL:

```yaml
image: <account-id>.dkr.ecr.<region>.amazonaws.com/eyegic-opticals:latest
```

### Update Ingress Domain

Update `k8s/ingress.yaml` with your domain name:

```yaml
host: your-domain.com  # Replace eyegic.example.com
```

## Step 4: Deploy to EKS

Deploy the application to your EKS cluster:

```bash
chmod +x deploy.sh
./deploy.sh
```

**Manual Deployment:**
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy application
kubectl apply -f k8s/deployment.yaml -n eyegic-opticals
kubectl apply -f k8s/service.yaml -n eyegic-opticals

# Deploy ingress (optional)
kubectl apply -f k8s/ingress.yaml -n eyegic-opticals

# Check deployment status
kubectl rollout status deployment/eyegic-opticals -n eyegic-opticals
```

## Step 5: Verify Deployment

Check if pods are running:

```bash
kubectl get pods -n eyegic-opticals
```

Check service:

```bash
kubectl get svc -n eyegic-opticals
```

Check ingress:

```bash
kubectl get ingress -n eyegic-opticals
```

## Step 6: Access the Application

### Option 1: Using Ingress (Recommended)

If you've configured an ingress with a domain:
- Access via: `https://your-domain.com`

### Option 2: Port Forwarding (Testing)

For quick testing without ingress:

```bash
kubectl port-forward -n eyegic-opticals svc/eyegic-opticals-service 8080:80
```

Then access: `http://localhost:8080`

### Option 3: LoadBalancer Service

If you want to expose via LoadBalancer, update `k8s/service.yaml`:

```yaml
spec:
  type: LoadBalancer  # Change from ClusterIP
```

Then get the external IP:

```bash
kubectl get svc eyegic-opticals-service -n eyegic-opticals
```

## Ingress Controller Setup

If you don't have an ingress controller installed:

### NGINX Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml
```

### AWS Load Balancer Controller (Alternative)

```bash
# Install AWS Load Balancer Controller
kubectl apply -k "https://github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=your-cluster-name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system
```

## SSL/TLS Certificate (Optional)

For HTTPS, you can use cert-manager with Let's Encrypt:

1. Install cert-manager:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. Create ClusterIssuer:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

## Updating the Application

To update the application:

1. Make changes to your code
2. Rebuild and push:
```bash
./build.sh v1.0.1
```

3. Update deployment:
```bash
kubectl set image deployment/eyegic-opticals eyegic-opticals=<new-image-url> -n eyegic-opticals
```

Or apply the updated manifest:
```bash
kubectl apply -f k8s/deployment.yaml -n eyegic-opticals
```

## Scaling

Scale the deployment:

```bash
kubectl scale deployment eyegic-opticals --replicas=3 -n eyegic-opticals
```

## Monitoring

View logs:

```bash
kubectl logs -f deployment/eyegic-opticals -n eyegic-opticals
```

View pod status:

```bash
kubectl describe pod <pod-name> -n eyegic-opticals
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n eyegic-opticals
kubectl logs <pod-name> -n eyegic-opticals
```

### Image pull errors
- Verify ECR repository exists
- Check IAM permissions for ECR
- Verify image tag is correct

### Service not accessible
- Check service type and selectors
- Verify ingress controller is installed
- Check ingress configuration

## Cleanup

To remove the deployment:

```bash
kubectl delete -f k8s/ -n eyegic-opticals
kubectl delete namespace eyegic-opticals
```

## File Structure

```
.
├── Dockerfile              # Docker image definition
├── nginx.conf             # Nginx configuration
├── build.sh               # Build and push script
├── deploy.sh              # Deployment script
├── setup-ecr.sh           # ECR setup script
├── k8s/
│   ├── namespace.yaml     # Kubernetes namespace
│   ├── deployment.yaml    # Application deployment
│   ├── service.yaml       # Kubernetes service
│   └── ingress.yaml       # Ingress configuration
└── DEPLOYMENT.md          # This file
```

## Additional Resources

- [EKS User Guide](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
