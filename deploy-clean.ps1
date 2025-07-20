# Simple Azure Function Deployment Script
Write-Host "🚀 Deploying Fact Checker to Azure..." -ForegroundColor Green

# Variables
$resourceGroup = "rg-fact-checker-demo"
$functionApp = "func-fact-checker-demo"
$storageAccount = "stfactcheckerdemo"
$location = "eastus"

# Check if already logged in
Write-Host "Checking Azure login..." -ForegroundColor Yellow
$account = az account show --query "user.name" -o tsv 2>$null
if (-not $account) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Create resource group if it doesn't exist
Write-Host "Ensuring resource group exists..." -ForegroundColor Yellow
$rgExists = az group exists --name $resourceGroup
if ($rgExists -eq "false") {
    az group create --name $resourceGroup --location $location
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group exists" -ForegroundColor Green
}

# Create storage account if it doesn't exist
Write-Host "Ensuring storage account exists..." -ForegroundColor Yellow
$storageExists = az storage account check-name --name $storageAccount --query "nameAvailable" -o tsv
if ($storageExists -eq "true") {
    az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_LRS
    Write-Host "✓ Storage account created" -ForegroundColor Green
} else {
    Write-Host "✓ Storage account exists" -ForegroundColor Green
}

# Create function app if it doesn't exist
Write-Host "Ensuring function app exists..." -ForegroundColor Yellow
$functionExists = az functionapp show --name $functionApp --resource-group $resourceGroup --query "name" -o tsv 2>$null
if (-not $functionExists) {
    az functionapp create --resource-group $resourceGroup --name $functionApp --storage-account $storageAccount --consumption-plan-location $location --runtime python --runtime-version 3.12 --os-type Linux
    Write-Host "✓ Function app created" -ForegroundColor Green
} else {
    Write-Host "✓ Function app exists" -ForegroundColor Green
}

# Deploy using Azure Functions Core Tools
Write-Host "Deploying function code..." -ForegroundColor Yellow
func azure functionapp publish $functionApp --python

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment successful!" -ForegroundColor Green
    $url = "https://$functionApp.azurewebsites.net/api/fact_check_function"
    Write-Host "Function URL: $url" -ForegroundColor Cyan
    $url | Out-File -FilePath "deployed-url.txt" -Encoding utf8
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}
