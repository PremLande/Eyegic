# Alternative: Deploy to S3 + CloudFront (Much Cheaper!)

Since this is a static website, deploying to **AWS S3 + CloudFront** will cost you **~$5-15/month** instead of **~$164/month** with EKS.

## Quick Setup Guide

### 1. Create S3 Bucket

```bash
# Create bucket
aws s3 mb s3://eyegic-opticals --region us-east-1

# Enable static website hosting
aws s3 website s3://eyegic-opticals \
  --index-document index.html \
  --error-document index.html
```

### 2. Upload Files

```bash
# Upload all files
aws s3 sync . s3://eyegic-opticals \
  --exclude "*.md" \
  --exclude ".git/*" \
  --exclude "k8s/*" \
  --exclude "*.sh" \
  --exclude "*.ps1" \
  --exclude "Dockerfile" \
  --exclude "nginx.conf" \
  --exclude ".dockerignore" \
  --exclude "Makefile"

# Set proper permissions
aws s3 cp s3://eyegic-opticals s3://eyegic-opticals \
  --recursive \
  --acl public-read
```

### 3. Create CloudFront Distribution

```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name eyegic-opticals.s3.amazonaws.com \
  --default-root-object index.html
```

### 4. Update DNS (Optional)

Point your domain to the CloudFront distribution URL.

## Cost Comparison

- **EKS:** ~$164/month
- **S3 + CloudFront:** ~$5-15/month
- **Savings:** ~$150/month = **$1,800/year**

## Benefits

✅ **90% cost reduction**  
✅ **Global CDN** (faster loading worldwide)  
✅ **Automatic HTTPS** (via CloudFront)  
✅ **Simple deployment** (just upload files)  
✅ **Scalable** (handles millions of requests)  
✅ **No server management**

## Automated Deployment Script

Create `deploy-s3.sh`:

```bash
#!/bin/bash
BUCKET="eyegic-opticals"
DISTRIBUTION_ID="your-cloudfront-distribution-id"

echo "Uploading files to S3..."
aws s3 sync . s3://$BUCKET \
  --exclude "*.md" \
  --exclude ".git/*" \
  --exclude "k8s/*" \
  --exclude "*.sh" \
  --exclude "*.ps1" \
  --exclude "Dockerfile" \
  --exclude "nginx.conf" \
  --exclude ".dockerignore" \
  --exclude "Makefile" \
  --delete

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"

echo "Deployment complete!"
```

## Recommendation

**For this static website, use S3 + CloudFront instead of EKS.**

You'll save ~$150/month while getting better performance and simpler deployment.
