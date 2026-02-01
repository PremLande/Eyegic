#!/bin/bash

# Configuration
AWS_REGION="us-east-1"  # Change to your preferred region
ECR_REPO_NAME="eyegic-opticals"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up ECR repository...${NC}"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Failed to get AWS account ID. Make sure AWS CLI is configured."
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_REPO_NAME="${ECR_REGISTRY}/${ECR_REPO_NAME}"

echo -e "${BLUE}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${BLUE}Region: ${AWS_REGION}${NC}"
echo -e "${BLUE}ECR Registry: ${ECR_REGISTRY}${NC}"

# Check if repository exists
echo -e "${BLUE}Checking if ECR repository exists...${NC}"
aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} &> /dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Repository not found. Creating ECR repository...${NC}"
    aws ecr create-repository \
        --repository-name ${ECR_REPO_NAME} \
        --region ${AWS_REGION} \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}ECR repository created successfully!${NC}"
    else
        echo "Failed to create ECR repository!"
        exit 1
    fi
else
    echo -e "${GREEN}ECR repository already exists!${NC}"
fi

# Update build.sh with the registry
echo -e "${BLUE}Updating build.sh with ECR registry...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|REGISTRY=\"your-ecr-registry.amazonaws.com\"|REGISTRY=\"${ECR_REGISTRY}\"|g" build.sh
else
    # Linux
    sed -i "s|REGISTRY=\"your-ecr-registry.amazonaws.com\"|REGISTRY=\"${ECR_REGISTRY}\"|g" build.sh
fi

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}Your ECR registry: ${FULL_REPO_NAME}${NC}"
echo -e "${BLUE}You can now run ./build.sh to build and push your image${NC}"
