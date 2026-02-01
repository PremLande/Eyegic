# PowerShell script to set up ECR repository

param(
    [string]$Region = "us-east-1"
)

# Configuration
$EcrRepoName = "eyegic-opticals"

Write-Host "Setting up ECR repository..." -ForegroundColor Blue

# Get AWS account ID
try {
    $AccountInfo = aws sts get-caller-identity --output json | ConvertFrom-Json
    $AwsAccountId = $AccountInfo.Account
} catch {
    Write-Host "Failed to get AWS account ID. Make sure AWS CLI is configured." -ForegroundColor Red
    exit 1
}

$EcrRegistry = "$AwsAccountId.dkr.ecr.$Region.amazonaws.com"
$FullRepoName = "$EcrRegistry/$EcrRepoName"

Write-Host "AWS Account ID: $AwsAccountId" -ForegroundColor Blue
Write-Host "Region: $Region" -ForegroundColor Blue
Write-Host "ECR Registry: $EcrRegistry" -ForegroundColor Blue

# Check if repository exists
Write-Host "Checking if ECR repository exists..." -ForegroundColor Blue
$RepoExists = aws ecr describe-repositories --repository-names $EcrRepoName --region $Region 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Repository not found. Creating ECR repository..." -ForegroundColor Yellow
    aws ecr create-repository `
        --repository-name $EcrRepoName `
        --region $Region `
        --image-scanning-configuration scanOnPush=true `
        --encryption-configuration encryptionType=AES256
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ECR repository created successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to create ECR repository!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ECR repository already exists!" -ForegroundColor Green
}

# Update build.ps1 with the registry
Write-Host "Updating build.ps1 with ECR registry..." -ForegroundColor Blue
$BuildScript = "build.ps1"
if (Test-Path $BuildScript) {
    $Content = Get-Content $BuildScript -Raw
    $Content = $Content -replace '`$Registry = "your-ecr-registry.amazonaws.com"', "`$Registry = `"$EcrRegistry`""
    Set-Content -Path $BuildScript -Value $Content -NoNewline
}

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Your ECR registry: $FullRepoName" -ForegroundColor Blue
Write-Host "You can now run .\build.ps1 to build and push your image" -ForegroundColor Blue
