# PowerShell script to build and push backend Docker image

param(
    [string]$Version = "latest"
)

# Configuration
$Registry = "your-ecr-registry.amazonaws.com"  # Replace with your ECR registry
$ImageName = "eyegic-opticals-backend"
$FullImageName = "$Registry/$ImageName`:$Version"

Write-Host "Building backend Docker image..." -ForegroundColor Blue

# Build Docker image
Set-Location backend
docker build -t "${ImageName}:${Version}" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Docker image built successfully!" -ForegroundColor Green
Write-Host "Tagging image for ECR..." -ForegroundColor Blue
docker tag "${ImageName}:${Version}" $FullImageName

Write-Host "Logging into ECR..." -ForegroundColor Blue
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

Write-Host "Backend image pushed successfully to $FullImageName" -ForegroundColor Green

Set-Location ..
