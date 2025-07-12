# Deploy Next.js App to Azure Static Web Apps
# This script creates and deploys a Static Web App using Azure CLI

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$StaticWebAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus2",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubBranch = "main",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken = ""
)

# Colors for output
$Green = "Green"
$Red = "Red" 
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🚀 Azure Static Web Apps Deployment Script" -ForegroundColor $Cyan
Write-Host "===========================================" -ForegroundColor $Cyan

# Check if Azure CLI is installed
Write-Host "📋 Checking prerequisites..." -ForegroundColor $Yellow
try {
    $azVersion = az --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI not found"
    }
    Write-Host "✅ Azure CLI is installed" -ForegroundColor $Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first:" -ForegroundColor $Red
    Write-Host "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor $Red
    exit 1
}

# Check if logged in to Azure
Write-Host "🔐 Checking Azure login status..." -ForegroundColor $Yellow
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        throw "Not logged in"
    }
    Write-Host "✅ Logged in to Azure as: $($account.user.name)" -ForegroundColor $Green
    Write-Host "   Subscription: $($account.name)" -ForegroundColor $Green
} catch {
    Write-Host "❌ Not logged in to Azure. Please run 'az login' first." -ForegroundColor $Red
    exit 1
}

# Check if Static Web Apps extension is installed
Write-Host "🔌 Checking Azure CLI extensions..." -ForegroundColor $Yellow
$extensions = az extension list --query "[?name=='staticwebapp'].name" -o tsv
if (-not $extensions -contains "staticwebapp") {
    Write-Host "📦 Installing Azure Static Web Apps CLI extension..." -ForegroundColor $Yellow
    az extension add --name staticwebapp
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Static Web Apps extension" -ForegroundColor $Red
        exit 1
    }
    Write-Host "✅ Static Web Apps extension installed" -ForegroundColor $Green
} else {
    Write-Host "✅ Static Web Apps extension is already installed" -ForegroundColor $Green
}

# Create resource group if it doesn't exist
Write-Host "📁 Checking resource group: $ResourceGroupName" -ForegroundColor $Yellow
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "false") {
    Write-Host "📁 Creating resource group: $ResourceGroupName" -ForegroundColor $Yellow
    az group create --name $ResourceGroupName --location $Location
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create resource group" -ForegroundColor $Red
        exit 1
    }
    Write-Host "✅ Resource group created" -ForegroundColor $Green
} else {
    Write-Host "✅ Resource group already exists" -ForegroundColor $Green
}

# Build the Next.js app
Write-Host "🔨 Building Next.js application..." -ForegroundColor $Yellow
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json not found. Make sure you're in the Next.js project directory." -ForegroundColor $Red
    exit 1
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor $Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor $Red
    exit 1
}

# Build the application
Write-Host "🏗️ Building application..." -ForegroundColor $Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed" -ForegroundColor $Red
    exit 1
}
Write-Host "✅ Application built successfully" -ForegroundColor $Green

# Deploy options
if ($GitHubRepo -and $GitHubToken) {
    # GitHub integration deployment
    Write-Host "🔗 Deploying with GitHub integration..." -ForegroundColor $Yellow
    
    $deployResult = az staticwebapp create `
        --name $StaticWebAppName `
        --resource-group $ResourceGroupName `
        --source $GitHubRepo `
        --location $Location `
        --branch $GitHubBranch `
        --app-location "/fact-checker-frontend" `
        --api-location "" `
        --output-location "out" `
        --login-with-github `
        --token $GitHubToken
        
} else {
    # Manual deployment (local files)
    Write-Host "📤 Deploying from local files..." -ForegroundColor $Yellow
    
    # Create Static Web App without GitHub integration
    $deployResult = az staticwebapp create `
        --name $StaticWebAppName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --output json
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed" -ForegroundColor $Red
    exit 1
}

# Parse deployment result
$app = $deployResult | ConvertFrom-Json
$appUrl = $app.defaultHostname

Write-Host "✅ Static Web App created successfully!" -ForegroundColor $Green
Write-Host "🌐 App URL: https://$appUrl" -ForegroundColor $Cyan

# If manual deployment, upload the files
if (-not ($GitHubRepo -and $GitHubToken)) {
    Write-Host "📤 Uploading application files..." -ForegroundColor $Yellow
    
    # Get deployment token
    $token = az staticwebapp secrets list --name $StaticWebAppName --resource-group $ResourceGroupName --query "properties.apiKey" -o tsv
    
    # Install SWA CLI if not present
    Write-Host "🔧 Checking SWA CLI..." -ForegroundColor $Yellow
    $swaInstalled = Get-Command "swa" -ErrorAction SilentlyContinue
    if (-not $swaInstalled) {
        Write-Host "📦 Installing SWA CLI..." -ForegroundColor $Yellow
        npm install -g @azure/static-web-apps-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install SWA CLI" -ForegroundColor $Red
            exit 1
        }
    }
    
    # Deploy using SWA CLI
    Write-Host "🚀 Deploying files using SWA CLI..." -ForegroundColor $Yellow
    swa deploy ./out --deployment-token $token
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ File upload failed" -ForegroundColor $Red
        exit 1
    }
}

Write-Host "🎉 Deployment completed successfully!" -ForegroundColor $Green
Write-Host "===========================================" -ForegroundColor $Cyan
Write-Host "📋 Deployment Summary:" -ForegroundColor $Cyan
Write-Host "   App Name: $StaticWebAppName" -ForegroundColor $Green
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor $Green
Write-Host "   URL: https://$appUrl" -ForegroundColor $Green
Write-Host ""
Write-Host "🔧 Next Steps:" -ForegroundColor $Yellow
Write-Host "1. Configure environment variables in Azure Portal:" -ForegroundColor $Yellow
Write-Host "   - Go to: https://portal.azure.com" -ForegroundColor $Yellow
Write-Host "   - Navigate to: $StaticWebAppName > Configuration" -ForegroundColor $Yellow
Write-Host "   - Add environment variables from .env.production" -ForegroundColor $Yellow
Write-Host "   - Update NEXTAUTH_URL to: https://$appUrl" -ForegroundColor $Yellow
Write-Host ""
Write-Host "2. Update OAuth provider redirect URIs:" -ForegroundColor $Yellow
Write-Host "   - Google Cloud Console: Add https://$appUrl/api/auth/callback/google" -ForegroundColor $Yellow
Write-Host "   - Facebook Developer Console: Add https://$appUrl/api/auth/callback/facebook" -ForegroundColor $Yellow
Write-Host ""
Write-Host "3. Test your deployed application at: https://$appUrl" -ForegroundColor $Yellow

# Save deployment info
$deploymentInfo = @{
    AppName = $StaticWebAppName
    ResourceGroup = $ResourceGroupName
    URL = "https://$appUrl"
    DeploymentDate = Get-Date
} | ConvertTo-Json

$deploymentInfo | Out-File "deployment-info.json" -Encoding UTF8
Write-Host "💾 Deployment info saved to deployment-info.json" -ForegroundColor $Green
