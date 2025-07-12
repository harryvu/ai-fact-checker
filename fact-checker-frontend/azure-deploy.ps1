# Azure Static Web Apps Deployment Script
# This script automates the deployment of the Next.js frontend to Azure Static Web Apps

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$StaticWebAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US 2",
    
    [Parameter(Mandatory=$false)]
    [string]$SkuName = "Free"
)

Write-Host "🚀 Starting Azure Static Web Apps deployment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it from https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
try {
    $account = az account show --query "name" -o tsv
    Write-Host "✅ Logged in to Azure as: $account" -ForegroundColor Green
} catch {
    Write-Host "❌ Not logged in to Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

# Create resource group if it doesn't exist
Write-Host "🔧 Creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Create Static Web App
Write-Host "🔧 Creating Static Web App '$StaticWebAppName'..." -ForegroundColor Yellow
az staticwebapp create `
    --name $StaticWebAppName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku $SkuName `
    --source "https://github.com/harryvu/ai-fact-checker" `
    --branch "main" `
    --app-location "/" `
    --output-location "out" `
    --login-with-github | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Static Web App. Please check the error above." -ForegroundColor Red
    exit 1
}

# Get the deployment token
Write-Host "🔑 Getting deployment token..." -ForegroundColor Yellow
$deploymentToken = az staticwebapp secrets list --name $StaticWebAppName --resource-group $ResourceGroupName --query "properties.apiKey" -o tsv

Write-Host "✅ Static Web App created successfully!" -ForegroundColor Green
Write-Host "🌐 URL: https://$StaticWebAppName.azurestaticapps.net" -ForegroundColor Cyan
Write-Host "🔑 Deployment Token: $deploymentToken" -ForegroundColor Cyan

# Save deployment info
$deploymentInfo = @{
    ResourceGroup = $ResourceGroupName
    StaticWebAppName = $StaticWebAppName
    URL = "https://$StaticWebAppName.azurestaticapps.net"
    DeploymentToken = $deploymentToken
    CreatedAt = Get-Date
} | ConvertTo-Json

$deploymentInfo | Out-File -FilePath "azure-deployment-info.json" -Encoding UTF8

Write-Host "📋 Deployment information saved to 'azure-deployment-info.json'" -ForegroundColor Green
Write-Host "🚀 Deployment complete! Next steps:" -ForegroundColor Green
Write-Host "   1. Update your .env.local file with the new NEXTAUTH_URL" -ForegroundColor White
Write-Host "   2. Update Google OAuth redirect URIs in Google Cloud Console" -ForegroundColor White
Write-Host "   3. Deploy your code using GitHub Actions or Azure CLI" -ForegroundColor White
