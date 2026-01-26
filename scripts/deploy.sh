#!/bin/bash

# Configuration
NAMESPACE="eyegic-opticals"
KUBECTL_CONTEXT=""  # Leave empty to use current context, or specify: --context=your-context

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Deploying to EKS cluster...${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if namespace exists, create if not
echo -e "${BLUE}Checking namespace...${NC}"
kubectl get namespace ${NAMESPACE} ${KUBECTL_CONTEXT} &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Namespace not found. Creating namespace...${NC}"
    kubectl apply -f k8s/namespace.yaml ${KUBECTL_CONTEXT}
fi

# Apply manifests
echo -e "${BLUE}Applying Kubernetes manifests...${NC}"
kubectl apply -f k8s/deployment.yaml -n ${NAMESPACE} ${KUBECTL_CONTEXT}
kubectl apply -f k8s/service.yaml -n ${NAMESPACE} ${KUBECTL_CONTEXT}

# Check if ingress should be applied (optional)
read -p "Do you want to apply Ingress configuration? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Applying Ingress...${NC}"
    kubectl apply -f k8s/ingress.yaml -n ${NAMESPACE} ${KUBECTL_CONTEXT}
fi

# Wait for deployment to be ready
echo -e "${BLUE}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/eyegic-opticals -n ${NAMESPACE} ${KUBECTL_CONTEXT} --timeout=300s

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment successful!${NC}"
    echo -e "${BLUE}Getting service information...${NC}"
    kubectl get svc eyegic-opticals-service -n ${NAMESPACE} ${KUBECTL_CONTEXT}
    kubectl get ingress eyegic-opticals-ingress -n ${NAMESPACE} ${KUBECTL_CONTEXT} 2>/dev/null || echo "No ingress found"
else
    echo "Deployment failed or timed out!"
    exit 1
fi
