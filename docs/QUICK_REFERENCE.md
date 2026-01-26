# Quick Reference Guide

## Project Structure

```
Eyegic/
├── infrastructure/          # Terraform infrastructure code
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Variable definitions
│   └── modules/            # Terraform modules
│       ├── vpc/            # VPC, subnets, networking
│       ├── eks/            # EKS cluster and IAM roles
│       └── rds/            # RDS PostgreSQL database
├── backend/                # Backend API (Node.js/Express)
│   ├── server.js          # Express server
│   ├── package.json        # Dependencies
│   └── Dockerfile          # Backend Docker image
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml      # Namespace
│   ├── deployment.yaml     # Frontend deployment
│   ├── service.yaml        # Frontend service
│   ├── backend-deployment.yaml  # Backend deployment
│   ├── backend-service.yaml     # Backend service
│   ├── db-secret.yaml      # Database credentials
│   └── ingress.yaml        # Ingress configuration
├── index.html              # Frontend HTML
├── styles.css              # Frontend styles
├── script.js               # Frontend JavaScript
└── Dockerfile              # Frontend Docker image
```

## Quick Commands

### Infrastructure

```bash
# Initialize Terraform
cd infrastructure
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Get outputs
terraform output
```

### Build Images

```bash
# Backend
./build-backend.sh
# or PowerShell: .\build-backend.ps1

# Frontend
./build.sh
# or PowerShell: .\build.ps1
```

### Deploy to Kubernetes

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create database secret
kubectl apply -f k8s/db-secret.yaml

# Deploy backend
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# Deploy frontend
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Deploy ingress
kubectl apply -f k8s/ingress.yaml
```

### Check Status

```bash
# Pods
kubectl get pods -n eyegic-opticals

# Services
kubectl get svc -n eyegic-opticals

# Logs
kubectl logs -f deployment/eyegic-backend -n eyegic-opticals
kubectl logs -f deployment/eyegic-opticals -n eyegic-opticals
```

## Environment Variables

### Backend (.env)
```
PORT=3000
DB_HOST=<rds-endpoint>
DB_PORT=5432
DB_NAME=eyegicdb
DB_USER=eyegicadmin
DB_PASSWORD=<password>
DB_SSL=true
```

### Frontend (Kubernetes)
```
API_BASE_URL=http://eyegic-backend-service:80
```

## API Endpoints

- `GET /health` - Health check
- `GET /api/enquiries` - Get all enquiries
- `POST /api/enquiries` - Create enquiry
- `GET /api/enquiries/:id` - Get enquiry by ID
- `DELETE /api/enquiries/:id` - Delete enquiry

## Database Schema

```sql
CREATE TABLE enquiries (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(50),
  message TEXT,
  product VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Troubleshooting

### Backend can't connect to database
1. Check RDS endpoint in secret
2. Verify security group allows traffic
3. Check database credentials

### Frontend can't reach backend
1. Verify backend service exists
2. Check API_BASE_URL configuration
3. Verify ingress routing

### Images not pulling
1. Check ECR repository exists
2. Verify IAM permissions
3. Check image tags

## Cost Estimate

- **EKS Control Plane:** $72/month
- **EC2 Nodes (2x t3.medium):** $61/month
- **RDS (db.t3.micro):** $15/month
- **NAT Gateways (2x):** $65/month
- **Total:** ~$213/month

## Documentation

- `DEPLOYMENT_FULL.md` - Complete deployment guide
- `infrastructure/README.md` - Infrastructure setup
- `COST_ANALYSIS.md` - Detailed cost breakdown
