# Project Structure

```
Eyegic/
├── README.md                    # Main project documentation
├── PROJECT_STRUCTURE.md         # This file
├── .gitignore                   # Git ignore rules
├── .dockerignore               # Docker ignore rules
├── Makefile                     # Make commands (Linux/Mac)
│
├── docs/                        # Documentation
│   ├── DEPLOYMENT_FULL.md      # Complete deployment guide
│   ├── QUICK_REFERENCE.md      # Quick command reference
│   ├── COST_ANALYSIS.md        # Cost breakdown and optimization
│   ├── s3-deployment.md        # Alternative S3 deployment
│   ├── DEPLOYMENT.md           # Original deployment guide
│   └── QUICKSTART.md           # Quick start guide
│
├── infrastructure/              # Terraform infrastructure
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   ├── terraform.tf            # Terraform settings
│   ├── terraform.tfvars.example # Example variables file
│   ├── .gitignore              # Terraform ignore rules
│   ├── README.md               # Infrastructure setup guide
│   └── modules/                # Terraform modules
│       ├── vpc/                # VPC module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── eks/                # EKS module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── rds/                # RDS module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── frontend/                    # Frontend application
│   ├── index.html              # Main HTML file
│   ├── styles.css              # CSS styles
│   ├── script.js               # JavaScript
│   ├── favicon.svg             # Favicon
│   ├── Dockerfile              # Frontend Docker image
│   └── nginx.conf              # Nginx configuration
│
├── backend/                     # Backend API
│   ├── server.js               # Express server
│   ├── package.json            # Node.js dependencies
│   ├── Dockerfile              # Backend Docker image
│   ├── .dockerignore           # Docker ignore rules
│   └── .env.example            # Environment variables example
│
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml          # Namespace definition
│   ├── deployment.yaml        # Frontend deployment
│   ├── service.yaml           # Frontend service
│   ├── backend-deployment.yaml # Backend deployment
│   ├── backend-service.yaml   # Backend service
│   ├── db-secret.yaml         # Database secret template
│   └── ingress.yaml           # Ingress configuration
│
└── scripts/                    # Build and deployment scripts
    ├── build.sh                # Build frontend (Linux/Mac)
    ├── build.ps1               # Build frontend (Windows)
    ├── build-backend.sh        # Build backend (Linux/Mac)
    ├── build-backend.ps1       # Build backend (Windows)
    ├── deploy.sh               # Deploy to EKS (Linux/Mac)
    ├── deploy.ps1              # Deploy to EKS (Windows)
    ├── setup-ecr.sh            # Setup ECR (Linux/Mac)
    └── setup-ecr.ps1           # Setup ECR (Windows)
```

## Directory Descriptions

### `/docs`
All documentation files including deployment guides, cost analysis, and quick references.

### `/infrastructure`
Terraform code for provisioning AWS infrastructure:
- VPC with public and private subnets
- EKS cluster with node groups
- RDS PostgreSQL database
- IAM roles and policies
- ECR repositories

### `/frontend`
Static website files served by Nginx:
- HTML, CSS, JavaScript
- Dockerfile for containerization
- Nginx configuration

### `/backend`
Node.js/Express API server:
- RESTful API endpoints
- PostgreSQL database connection
- Dockerfile for containerization

### `/k8s`
Kubernetes manifests for deploying the application:
- Deployments for frontend and backend
- Services for internal communication
- Ingress for external access
- Secrets for sensitive data

### `/scripts`
Automation scripts for building and deploying:
- Build scripts for Docker images
- Deployment scripts for Kubernetes
- ECR setup scripts
