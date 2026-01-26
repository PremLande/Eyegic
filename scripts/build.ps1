# PowerShell script to build and push Docker image to ECR

param(
    [string]$Version = "latest"
)

# Configuration
$Registry = "your-ecr-registry.amazonaws.com"  # Replace with your ECR registry
$ImageName = "eyegic-opticals"
$FullImageName = "$Registry/$ImageName`:$Version"

Write-Host "Building Docker image..." -ForegroundColor Blue

# Build Docker image
docker build -t "${ImageName}:${Version}" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Docker image built successfully!" -ForegroundColor Green
Write-Host "Tagging image for ECR..." -ForegroundColor Blue
docker tag "${ImageName}:${Version}" $FullImageName

Write-Host "Logging into ECR..." -ForegroundColor Blue
# Get AWS region from registry or set default
$Region = "us-east-1"
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $Registry

if ($LASTEXITCODE -ne 0) {
    Write-Host "ECR login failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Pushing image to ECR..." -ForegroundColor Blue
docker push $FullImageName

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker push failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Image pushed successfully to $FullImageName" -ForegroundColor Green

# Update deployment.yaml with the new image
$DeploymentFile = "k8s\deployment.yaml"
if (Test-Path $DeploymentFile) {
    $Content = Get-Content $DeploymentFile -Raw
    $Content = $Content -replace "image: eyegic-opticals:latest", "image: $FullImageName"
    Set-Content -Path $DeploymentFile -Value $Content -NoNewline
    Write-Host "Deployment manifest updated!" -ForegroundColor Green
}
