# Cost Analysis - EKS Deployment

## Monthly Cost Breakdown (Estimated)

### 1. **EKS Cluster Control Plane**
- **Cost:** $0.10 per hour = **$72/month**
- This is a fixed cost regardless of usage
- Required for any EKS cluster

### 2. **EC2 Worker Nodes** (Minimum recommended: 2 nodes for high availability)
- **Option A: t3.small instances** (2GB RAM, 2 vCPU)
  - Cost: ~$0.0208/hour per instance
  - 2 nodes × $0.0208 × 730 hours = **$30.37/month**
  
- **Option B: t3.medium instances** (4GB RAM, 2 vCPU) - Recommended
  - Cost: ~$0.0416/hour per instance
  - 2 nodes × $0.0416 × 730 hours = **$60.74/month**

- **Option C: t3.large instances** (8GB RAM, 2 vCPU)
  - Cost: ~$0.0832/hour per instance
  - 2 nodes × $0.0832 × 730 hours = **$121.47/month**

### 3. **ECR Storage** (Docker images)
- First 500MB: **Free**
- Additional: $0.10 per GB/month
- Estimated: **$0-1/month** (very small for static site)

### 4. **Load Balancer** (if using ALB/NLB)
- **Application Load Balancer (ALB):**
  - Fixed cost: $0.0225/hour = **$16.43/month**
  - LCU charges: ~$0.008 per LCU-hour (varies by usage)
  - Estimated total: **$20-30/month**

- **Network Load Balancer (NLB):**
  - Fixed cost: $0.0225/hour = **$16.43/month**
  - NLCU charges: ~$0.006 per NLCU-hour
  - Estimated total: **$20-25/month**

### 5. **Data Transfer**
- First 100GB: **Free** (outbound)
- Additional: $0.09 per GB
- Estimated for small-medium traffic: **$0-10/month**

### 6. **Ingress Controller** (if using AWS Load Balancer Controller)
- Uses ALB/NLB (included above)
- No additional cost

## Total Monthly Cost Estimates

### **Minimum Setup** (t3.small, no ALB, low traffic)
- EKS Control Plane: $72
- EC2 Nodes (2x t3.small): $30
- ECR: $1
- **Total: ~$103/month**

### **Recommended Setup** (t3.medium, ALB, moderate traffic)
- EKS Control Plane: $72
- EC2 Nodes (2x t3.medium): $61
- ALB: $25
- ECR: $1
- Data Transfer: $5
- **Total: ~$164/month**

### **Production Setup** (t3.large, ALB, high traffic)
- EKS Control Plane: $72
- EC2 Nodes (2x t3.large): $121
- ALB: $30
- ECR: $1
- Data Transfer: $15
- **Total: ~$239/month**

## Cost Optimization Strategies

### 1. **Use Spot Instances** (Save up to 90%)
- Use Spot instances for worker nodes
- Can reduce EC2 costs to **$6-12/month** (instead of $30-121)
- Risk: Instances can be terminated, but fine for static sites
- **New Total: ~$100-120/month**

### 2. **Use Fargate Instead of EC2** (Pay per pod)
- No EC2 nodes to manage
- Pay only for running pods
- Estimated: **$15-30/month** for 2 pods
- **New Total: ~$110-130/month**

### 3. **Single Node Setup** (Development/Testing)
- Use 1 node instead of 2
- Reduces EC2 cost by 50%
- **New Total: ~$80-120/month**
- ⚠️ Not recommended for production (no high availability)

### 4. **Use Smaller Instance Types**
- t3.micro or t3.nano for very low traffic
- **New Total: ~$90-100/month**
- ⚠️ May have performance issues

## ⚠️ Important: Static Site Alternative

Since this is a **static website**, consider these cheaper alternatives:

### **AWS S3 + CloudFront** (Recommended for static sites)
- S3 Storage: $0.023 per GB/month (~$0.10/month for small site)
- CloudFront: $0.085 per GB (first 10TB)
- Route 53: $0.50 per hosted zone
- **Total: ~$5-15/month** (depending on traffic)
- **Savings: ~$150/month** compared to EKS

### **AWS Amplify**
- Free tier: 15GB storage, 5GB/month transfer
- Paid: ~$0.15/GB storage, $0.15/GB transfer
- **Total: ~$5-20/month**

### **GitHub Pages + Cloudflare**
- **Free** (if using GitHub)
- Cloudflare CDN: **Free**

## When to Use EKS vs. Static Hosting

### Use EKS if:
- ✅ You need dynamic backend services
- ✅ You plan to add microservices
- ✅ You need Kubernetes features (scaling, service mesh, etc.)
- ✅ You have multiple applications to deploy
- ✅ You need advanced networking/routing

### Use Static Hosting (S3/Amplify) if:
- ✅ You only have a static website (like this one)
- ✅ You want to minimize costs
- ✅ You don't need Kubernetes features
- ✅ You want simpler deployment

## Cost Comparison Summary

| Solution | Monthly Cost | Best For |
|----------|-------------|----------|
| **EKS (Minimum)** | ~$103 | Dynamic apps, microservices |
| **EKS (Recommended)** | ~$164 | Production workloads |
| **EKS (Fargate)** | ~$110-130 | Serverless containers |
| **S3 + CloudFront** | ~$5-15 | Static websites ⭐ |
| **AWS Amplify** | ~$5-20 | Static sites with CI/CD |
| **GitHub Pages** | Free | Personal/small projects |

## Recommendations

1. **For this static website:** Use **S3 + CloudFront** to save ~$150/month
2. **If you need EKS:** Use **Fargate** or **Spot instances** to reduce costs
3. **For development:** Use a **single node** or **local testing**
4. **For production:** Use **2+ nodes** with **ALB** for high availability

## Additional Cost Considerations

- **Reserved Instances:** Save up to 72% with 1-3 year commitments
- **Savings Plans:** Flexible pricing, save up to 72%
- **Data Transfer:** Minimize by using CloudFront/CDN
- **Monitoring:** CloudWatch costs (~$0.30/GB ingested)
- **Backup:** EBS snapshots (~$0.05/GB/month)

## Cost Monitoring

Set up AWS Cost Explorer and Budgets to track spending:
```bash
# Set up budget alert
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

## Conclusion

**EKS is overkill for a static website.** Consider migrating to S3 + CloudFront to reduce costs by ~90% while maintaining excellent performance and global CDN distribution.

If you must use EKS, optimize costs with Fargate or Spot instances.
