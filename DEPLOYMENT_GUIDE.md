# Azure Deployment Guide for Fact Checker API

## Prerequisites

Before deploying, make sure you have:
1. Azure CLI installed and logged in
2. An active Azure subscription
3. The Azure Functions Core Tools (already installed)

## Step 1: Login to Azure

Open a NEW PowerShell terminal (keep your function running in the current one) and run:

```powershell
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

## Step 2: Create Azure Resources

```powershell
# Set variables (customize these)
$resourceGroup = "rg-fact-checker"
$location = "eastus"
$storageAccount = "stfactchecker$(Get-Random)"
$functionApp = "func-fact-checker-$(Get-Random)"
$appServicePlan = "asp-fact-checker"

# Create resource group
az group create --name $resourceGroup --location $location

# Create storage account
az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_LRS

# Create App Service Plan (Linux)
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --location $location --sku B1 --is-linux

# Create Function App with Python 3.12
az functionapp create --resource-group $resourceGroup --name $functionApp --storage-account $storageAccount --plan $appServicePlan --runtime python --runtime-version 3.12 --os-type Linux
```

## Step 3: Configure Application Settings

```powershell
# Set the Perplexity API key
az functionapp config appsettings set --name $functionApp --resource-group $resourceGroup --settings "PPLX_API_KEY=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"

# Optional: Set other settings
az functionapp config appsettings set --name $functionApp --resource-group $resourceGroup --settings "FUNCTIONS_WORKER_RUNTIME_VERSION=3.12"
```

## Step 4: Deploy the Function

Navigate to your project directory and deploy:

```powershell
# Navigate to your project directory
cd C:\repos\playground\fact-checker-demo

# Deploy the function
func azure functionapp publish $functionApp --python
```

## Step 5: Test the Deployed Function

After deployment, you'll get a URL like:
`https://func-fact-checker-12345.azurewebsites.net/api/fact_check_function`

Test it:
```powershell
# Test GET request
$functionUrl = "https://YOUR_FUNCTION_APP_NAME.azurewebsites.net/api/fact_check_function"
Invoke-RestMethod -Uri $functionUrl -Method GET

# Test POST request
$body = @{
    text = "The Earth is flat."
    model = "sonar-pro"
} | ConvertTo-Json

Invoke-RestMethod -Uri $functionUrl -Method POST -Body $body -ContentType "application/json"
```

## Step 6: Monitor and Manage

```powershell
# View logs
az functionapp logs show --name $functionApp --resource-group $resourceGroup

# Get function URL
az functionapp show --name $functionApp --resource-group $resourceGroup --query "defaultHostName" --output tsv
```

## Important Notes

1. **Python Version**: The function will run on Python 3.12 in Azure (as specified in the deployment)
2. **Pricing**: The B1 App Service Plan costs around $13/month. You can use a Consumption plan for cheaper costs
3. **Environment Variables**: Your API key is securely stored in Azure Function App Settings
4. **Scaling**: Azure Functions automatically scale based on demand

## Troubleshooting

If deployment fails:
- Check that all resource names are unique
- Verify your Azure subscription has sufficient permissions
- Check the deployment logs: `func azure functionapp logstream $functionApp`

## Alternative: Use Consumption Plan (Cheaper)

For a pay-per-use model, replace the App Service Plan creation with:

```powershell
# Create Function App with Consumption plan
az functionapp create --resource-group $resourceGroup --name $functionApp --storage-account $storageAccount --consumption-plan-location $location --runtime python --runtime-version 3.12 --os-type Linux
```

This charges only when your function executes, starting from $0.000016 per execution.
