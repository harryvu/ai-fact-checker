# Simplified Azure Deployment Script with Error Handling
Write-Host "🔄 Deploying Fact Checker API..." -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

# Check Azure login
try {
    $account = az account show --query "name" -o tsv 2>$null
    Write-Host "✓ Logged in as: $account" -ForegroundColor Green
} catch {
    Write-Host "Please login to Azure first:" -ForegroundColor Red
    az login
}

# Set variables with fixed names
$resourceGroup = "rg-fact-checker-demo"
$location = "eastus"
$storageAccount = "stfactcheckerdemo"
$functionApp = "func-fact-checker-demo"

Write-Host "`nDeployment Configuration:" -ForegroundColor Cyan
Write-Host "Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "Storage Account: $storageAccount" -ForegroundColor White
Write-Host "Function App: $functionApp" -ForegroundColor White

# Check if resource group exists, if not create it
Write-Host "`n1. Checking/Creating resource group..." -ForegroundColor Yellow
$existingRg = az group show --name $resourceGroup 2>$null
if ($existingRg) {
    Write-Host "✓ Resource group already exists" -ForegroundColor Green
} else {
    $result = az group create --name $resourceGroup --location $location --output json | ConvertFrom-Json
    if ($result.properties.provisioningState -eq "Succeeded") {
        Write-Host "✓ Resource group created successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create resource group" -ForegroundColor Red
        exit 1
    }
}

# Check if storage account exists, if not create it
Write-Host "`n2. Checking/Creating storage account..." -ForegroundColor Yellow
$existingStorage = az storage account show --name $storageAccount --resource-group $resourceGroup 2>$null
if ($existingStorage) {
    Write-Host "✓ Storage account already exists" -ForegroundColor Green
} else {
    $result = az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_LRS --output json | ConvertFrom-Json
    if ($result.provisioningState -eq "Succeeded") {
        Write-Host "✓ Storage account created successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create storage account" -ForegroundColor Red
        exit 1
    }
}

# Check if Function App exists, if not create it
Write-Host "`n3. Checking/Creating Function App..." -ForegroundColor Yellow
$existingFunction = az functionapp show --name $functionApp --resource-group $resourceGroup 2>$null
if ($existingFunction) {
    Write-Host "✓ Function App already exists" -ForegroundColor Green
} else {
    $result = az functionapp create --resource-group $resourceGroup --name $functionApp --storage-account $storageAccount --consumption-plan-location $location --runtime python --runtime-version 3.12 --os-type Linux --output json | ConvertFrom-Json
    if ($result.state -eq "Running") {
        Write-Host "✓ Function App created successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ Function App created (may still be starting)" -ForegroundColor Yellow
    }
}

# Set application settings
Write-Host "`n4. Setting application settings..." -ForegroundColor Yellow
az functionapp config appsettings set --name $functionApp --resource-group $resourceGroup --settings "PPLX_API_KEY=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" --output none
Write-Host "✓ API key configured" -ForegroundColor Green

# Deploy the function
Write-Host "`n5. Deploying function code..." -ForegroundColor Yellow
Write-Host "This will take a few minutes..." -ForegroundColor Cyan
try {
    func azure functionapp publish $functionApp --python
    Write-Host "✓ Function deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Final verification
Write-Host "`n6. Verifying deployment..." -ForegroundColor Yellow
$functionUrl = "https://$functionApp.azurewebsites.net/api/fact_check_function"
$appStatus = az functionapp show --name $functionApp --resource-group $resourceGroup --query "state" --output tsv

Write-Host "`n🎉 Deployment Summary:" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "✓ Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "✓ Function App: $functionApp" -ForegroundColor White
Write-Host "✓ App Status: $appStatus" -ForegroundColor White
Write-Host "✓ Function URL: $functionUrl" -ForegroundColor Cyan
Write-Host "✓ Runtime: Python 3.12" -ForegroundColor White

Write-Host "`nWait 2-3 minutes for the function to warm up, then test with:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri '$functionUrl' -Method GET" -ForegroundColor Gray

# Save the URL for easy access
$functionUrl | Out-File -FilePath "deployed-url.txt" -Encoding utf8
Write-Host "`nFunction URL saved to 'deployed-url.txt'" -ForegroundColor Green
