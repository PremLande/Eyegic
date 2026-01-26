#!/bin/bash

# Configuration
REGISTRY="your-ecr-registry.amazonaws.com"  # Replace with your ECR registry
IMAGE_NAME="eyegic-opticals"
VERSION="${1:-latest}"
FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${VERSION}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:${VERSION} .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

echo -e "${GREEN}Docker image built successfully!${NC}"
echo -e "${BLUE}Tagging image for ECR...${NC}"
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}

echo -e "${BLUE}Logging into ECR...${NC}"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REGISTRY}

if [ $? -ne 0 ]; then
    echo "ECR login failed!"
    exit 1
fi

echo -e "${BLUE}Pushing image to ECR...${NC}"
docker push ${FULL_IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "Docker push failed!"
    exit 1
fi

echo -e "${GREEN}Image pushed successfully to ${FULL_IMAGE_NAME}${NC}"

# Update deployment.yaml with the new image
sed -i.bak "s|image: eyegic-opticals:latest|image: ${FULL_IMAGE_NAME}|g" k8s/deployment.yaml
rm k8s/deployment.yaml.bak 2>/dev/null

echo -e "${GREEN}Deployment manifest updated!${NC}"
