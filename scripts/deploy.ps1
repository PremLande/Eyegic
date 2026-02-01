# PowerShell script to deploy to EKS cluster

param(
    [string]$Context = ""
)

# Configuration
$Namespace = "eyegic-opticals"
$KubectlContext = if ($Context) { "--context=$Context" } else { "" }

Write-Host "Deploying to EKS cluster..." -ForegroundColor Blue

# Check if kubectl is installed
try {
    kubectl version --client --short | Out-Null
} catch {
    Write-Host "kubectl is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if namespace exists, create if not
Write-Host "Checking namespace..." -ForegroundColor Blue
$NamespaceExists = kubectl get namespace $Namespace $KubectlContext 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Namespace not found. Creating namespace..." -ForegroundColor Yellow
    kubectl apply -f k8s\namespace.yaml $KubectlContext
}

# Apply manifests
Write-Host "Applying Kubernetes manifests..." -ForegroundColor Blue
kubectl apply -f k8s\deployment.yaml -n $Namespace $KubectlContext
kubectl apply -f k8s\service.yaml -n $Namespace $KubectlContext

# Ask about ingress
$ApplyIngress = Read-Host "Do you want to apply Ingress configuration? (y/n)"
if ($ApplyIngress -eq "y" -or $ApplyIngress -eq "Y") {
    Write-Host "Applying Ingress..." -ForegroundColor Blue
    kubectl apply -f k8s\ingress.yaml -n $Namespace $KubectlContext
}

# Wait for deployment to be ready
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Blue
kubectl rollout status deployment/eyegic-opticals -n $Namespace $KubectlContext --timeout=300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host "Getting service information..." -ForegroundColor Blue
    kubectl get svc eyegic-opticals-service -n $Namespace $KubectlContext
    $Ingress = kubectl get ingress eyegic-opticals-ingress -n $Namespace $KubectlContext 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host $Ingress
    } else {
        Write-Host "No ingress found" -ForegroundColor Yellow
    }
} else {
    Write-Host "Deployment failed or timed out!" -ForegroundColor Red
    exit 1
}
