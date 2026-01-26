# Infrastructure Setup with Terraform

This directory contains Terraform configuration to provision AWS infrastructure for the Eyegic Opticals application.

## Architecture

- **VPC** with public and private subnets across 2 availability zones
- **EKS Cluster** for container orchestration
- **RDS PostgreSQL** database in private subnets
- **ECR Repositories** for frontend and backend Docker images
- **IAM Roles** for EKS cluster and node groups

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** >= 1.0 installed
3. **kubectl** installed
4. AWS account with appropriate permissions

## Setup Instructions

### 1. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `aws_region` - Your preferred AWS region
- `db_password` - Strong password for RDS database
- Other values as needed

### 2. Initialize Terraform

```bash
cd infrastructure
terraform init
```

### 3. Plan Deployment

Review what will be created:

```bash
terraform plan
```

### 4. Apply Infrastructure

Create all resources:

```bash
terraform apply
```

This will take approximately 15-20 minutes to complete.

### 5. Configure kubectl

After Terraform completes, configure kubectl to connect to your EKS cluster:

```bash
aws eks update-kubeconfig --name eyegic-opticals-cluster --region us-east-1
```

Verify connection:

```bash
kubectl get nodes
```

### 6. Get Outputs

Get important values:

```bash
terraform output
```

Key outputs:
- `eks_cluster_id` - EKS Cluster ID
- `rds_endpoint` - RDS database endpoint (sensitive)
- `frontend_ecr_repository_url` - ECR URL for frontend
- `backend_ecr_repository_url` - ECR URL for backend

### 7. Update Kubernetes Secrets

Update the database secret in Kubernetes:

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Update secret
kubectl create secret generic eyegic-db-secret \
  --from-literal=db-host=$RDS_ENDPOINT \
  --from-literal=db-name=eyegicdb \
  --from-literal=db-user=eyegicadmin \
  --from-literal=db-password=YOUR_DB_PASSWORD \
  -n eyegic-opticals \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Infrastructure Components

### VPC Module (`modules/vpc`)
- VPC with DNS support
- Public subnets (for load balancers)
- Private subnets (for EKS nodes and RDS)
- Internet Gateway
- NAT Gateways (one per availability zone)
- Route tables and associations

### EKS Module (`modules/eks`)
- EKS Cluster with IAM role
- Managed Node Group with IAM role
- ECR repositories for frontend and backend

### RDS Module (`modules/rds`)
- PostgreSQL 15.4 database
- DB subnet group in private subnets
- Security group allowing access from EKS
- Automated backups and encryption

## Cost Estimation

- **EKS Control Plane:** ~$72/month
- **EC2 Nodes (2x t3.medium):** ~$61/month
- **RDS (db.t3.micro):** ~$15/month
- **NAT Gateways (2x):** ~$65/month
- **Data Transfer:** ~$5-10/month
- **Total:** ~$218-223/month

## Updating Infrastructure

To update infrastructure:

```bash
terraform plan
terraform apply
```

## Destroying Infrastructure

⚠️ **Warning:** This will delete all resources including the database!

```bash
terraform destroy
```

## Troubleshooting

### Terraform State Lock
If you see a state lock error:
```bash
terraform force-unlock <LOCK_ID>
```

### EKS Node Group Not Joining
Check node group status:
```bash
aws eks describe-nodegroup --cluster-name eyegic-opticals-cluster --nodegroup-name eyegic-opticals-node-group
```

### RDS Connection Issues
- Verify security group allows traffic from EKS
- Check RDS endpoint is correct
- Verify database credentials

## Next Steps

After infrastructure is created:

1. Build and push Docker images to ECR
2. Deploy frontend and backend to EKS
3. Configure ingress for external access
4. Set up monitoring and logging

See the main `DEPLOYMENT.md` for application deployment instructions.
