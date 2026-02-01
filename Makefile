.PHONY: help setup build deploy clean

# Configuration
REGISTRY ?= your-ecr-registry.amazonaws.com
IMAGE_NAME = eyegic-opticals
VERSION ?= latest
NAMESPACE = eyegic-opticals

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

setup: ## Set up ECR repository
	@echo "Setting up ECR repository..."
	@bash setup-ecr.sh

build: ## Build and push Docker image
	@echo "Building Docker image..."
	@bash build.sh $(VERSION)

deploy: ## Deploy to EKS cluster
	@echo "Deploying to EKS..."
	@bash deploy.sh

build-deploy: build deploy ## Build and deploy in one step

clean: ## Clean up local Docker images
	@echo "Cleaning up local images..."
	@docker rmi $(IMAGE_NAME):$(VERSION) || true
	@docker rmi $(REGISTRY)/$(IMAGE_NAME):$(VERSION) || true

logs: ## View application logs
	@kubectl logs -f deployment/eyegic-opticals -n $(NAMESPACE)

status: ## Check deployment status
	@kubectl get pods -n $(NAMESPACE)
	@kubectl get svc -n $(NAMESPACE)
	@kubectl get ingress -n $(NAMESPACE) || echo "No ingress found"

port-forward: ## Port forward to localhost:8080
	@kubectl port-forward -n $(NAMESPACE) svc/eyegic-opticals-service 8080:80

delete: ## Delete deployment from cluster
	@echo "Deleting deployment..."
	@kubectl delete -f k8s/ -n $(NAMESPACE) || true
	@kubectl delete namespace $(NAMESPACE) || true
