# Quick Azure Static Web Apps Deployment
# This script prepares and deploys your Next.js app to Azure Static Web Apps

param(
    [Parameter(Mandatory=$false)]
    [string]$StaticWebAppName = "fact-checker-app-$(Get-Random -Maximum 9999)",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-fact-checker",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US 2"
)

Write-Host "🚀 Quick Azure Static Web Apps Deployment" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "   Download from: https://aka.ms/installazurecliwindows" -ForegroundColor White
    exit 1
}

# Check if logged in to Azure
try {
    $account = az account show --query "name" -o tsv 2>$null
    if (-not $account) {
        Write-Host "❌ Not logged in to Azure. Running 'az login'..." -ForegroundColor Yellow
        az login
    } else {
        Write-Host "✅ Logged in to Azure as: $account" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Azure login failed. Please run 'az login' manually." -ForegroundColor Red
    exit 1
}

# Check Node.js and npm
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "✅ Node.js $nodeVersion and npm $npmVersion are installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js or npm not found. Please install Node.js." -ForegroundColor Red
    exit 1
}

Write-Host "`n🔧 Setting up Azure resources..." -ForegroundColor Yellow

# Create resource group
Write-Host "Creating resource group '$ResourceGroupName'..." -ForegroundColor White
az group create --name $ResourceGroupName --location $Location --output none

# Create Static Web App
Write-Host "Creating Static Web App '$StaticWebAppName'..." -ForegroundColor White
Write-Host "   This will open a browser for GitHub authentication..." -ForegroundColor Yellow

$result = az staticwebapp create `
    --name $StaticWebAppName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Free `
    --source "." `
    --branch main `
    --app-location "fact-checker-frontend" `
    --output-location "out" `
    --login-with-github

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Static Web App. Please check the error above." -ForegroundColor Red
    exit 1
}

# Get deployment information
Write-Host "`n🔑 Retrieving deployment information..." -ForegroundColor Yellow
$deploymentToken = az staticwebapp secrets list --name $StaticWebAppName --resource-group $ResourceGroupName --query "properties.apiKey" -o tsv
$appUrl = "https://$StaticWebAppName.azurestaticapps.net"

# Save deployment information
$deploymentInfo = @{
    StaticWebAppName = $StaticWebAppName
    ResourceGroup = $ResourceGroupName
    URL = $appUrl
    DeploymentToken = $deploymentToken
    Location = $Location
    CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
} | ConvertTo-Json -Depth 10

$deploymentInfo | Out-File -FilePath "azure-deployment-info.json" -Encoding UTF8

Write-Host "`n✅ Deployment successful!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "🌐 Your app URL: $appUrl" -ForegroundColor Cyan
Write-Host "📋 Deployment info saved to: azure-deployment-info.json" -ForegroundColor White
Write-Host "🔑 Deployment token: $deploymentToken" -ForegroundColor White

Write-Host "`n🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure GitHub repository secrets with the deployment token" -ForegroundColor White
Write-Host "2. Update OAuth redirect URIs in Google/Facebook consoles" -ForegroundColor White
Write-Host "3. Push your code to trigger the first deployment" -ForegroundColor White
Write-Host "4. Visit your app at: $appUrl" -ForegroundColor White

Write-Host "`n📚 For detailed instructions, see: AZURE_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan

# Open the deployment guide
if (Test-Path "AZURE_DEPLOYMENT_GUIDE.md") {
    $openGuide = Read-Host "`nWould you like to open the deployment guide? (y/n)"
    if ($openGuide -eq 'y' -or $openGuide -eq 'Y') {
        Start-Process "AZURE_DEPLOYMENT_GUIDE.md"
    }
}

Write-Host "`n🎉 Deployment script completed!" -ForegroundColor Green
