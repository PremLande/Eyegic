# Eyegic Opticals - Full Stack Application

A professional opticals website with frontend, backend API, and PostgreSQL database, deployed on AWS EKS.

## 🏗️ Architecture

```
Internet
   ↓
Ingress Controller (ALB)
   ↓
Frontend (EKS - Public Subnet) → Backend API (EKS - Private Subnet) → RDS PostgreSQL (Private Subnet)
```

## 📁 Project Structure

See [PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for detailed structure.

```
Eyegic/
├── docs/                    # Documentation
├── infrastructure/          # Terraform infrastructure code
├── frontend/               # Frontend application
├── backend/                # Backend API (Node.js/Express)
├── k8s/                    # Kubernetes manifests
└── scripts/                # Build and deployment scripts
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl installed
- Docker installed

### 1. Provision Infrastructure

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --name eyegic-opticals-cluster --region us-east-1
```

### 3. Build and Deploy

```bash
# Build backend
cd scripts
./build-backend.sh  # or .\build-backend.ps1 on Windows

# Build frontend
./build.sh  # or .\build.ps1 on Windows

# Deploy to Kubernetes
./deploy.sh  # or .\deploy.ps1 on Windows
```

## 📚 Documentation

- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Detailed project structure
- **[Complete Deployment Guide](docs/DEPLOYMENT_FULL.md)** - Step-by-step deployment instructions
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Quick command reference
- **[Cost Analysis](docs/COST_ANALYSIS.md)** - Detailed cost breakdown and optimization
- **[Infrastructure Setup](infrastructure/README.md)** - Terraform infrastructure guide
- **[S3 Alternative](docs/s3-deployment.md)** - Cheaper deployment option for static sites

## 🛠️ Features

- **Frontend**: Professional opticals website with responsive design
- **Backend API**: RESTful API for managing customer enquiries
- **Database**: PostgreSQL database for data persistence
- **Infrastructure**: Fully automated Terraform infrastructure
- **Kubernetes**: Containerized deployment on EKS
- **CI/CD Ready**: Build scripts for easy deployment

## 💰 Cost Estimate

- **EKS Control Plane:** ~$72/month
- **EC2 Nodes (2x t3.medium):** ~$61/month
- **RDS (db.t3.micro):** ~$15/month
- **NAT Gateways (2x):** ~$65/month
- **Total:** ~$213/month

See [Cost Analysis](docs/COST_ANALYSIS.md) for detailed breakdown and optimization strategies.

## 🔧 Development

### Local Development

#### Backend

```bash
cd backend
npm install
# Create .env file with database credentials
npm run dev
```

#### Frontend

```bash
cd frontend
# Open index.html in browser or use a local server
python -m http.server 8000
```

### Update Application

1. Make changes to code
2. Rebuild Docker images
3. Push to ECR
4. Restart Kubernetes deployments

## 📝 API Endpoints

- `GET /health` - Health check
- `GET /api/enquiries` - Get all enquiries
- `POST /api/enquiries` - Create enquiry
- `GET /api/enquiries/:id` - Get enquiry by ID
- `DELETE /api/enquiries/:id` - Delete enquiry

## 🧪 Testing

### Test Backend

```bash
kubectl port-forward -n eyegic-opticals svc/eyegic-backend-service 3000:80
curl http://localhost:3000/health
curl http://localhost:3000/api/enquiries
```

### Test Frontend

```bash
kubectl port-forward -n eyegic-opticals svc/eyegic-opticals-service 8080:80
# Open http://localhost:8080 in browser
```

## 🗑️ Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/ -n eyegic-opticals
kubectl delete namespace eyegic-opticals

# Destroy infrastructure
cd infrastructure
terraform destroy
```

## 📄 License

This project is for demonstration purposes.

## 🤝 Contributing

This is a private project. For questions or issues, please contact the maintainer.
