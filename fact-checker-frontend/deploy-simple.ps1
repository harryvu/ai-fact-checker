# Simple deployment script using SWA CLI
# This is a simpler alternative that uses the Static Web Apps CLI

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName = "fact-checker-app",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "rg-fact-checker",
    
    [Parameter(Mandatory=$false)]
    [string]$Subscription = ""
)

Write-Host "🚀 Simple Static Web Apps Deployment" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Check if SWA CLI is installed
$swaInstalled = Get-Command "swa" -ErrorAction SilentlyContinue
if (-not $swaInstalled) {
    Write-Host "📦 Installing SWA CLI..." -ForegroundColor Yellow
    npm install -g @azure/static-web-apps-cli
}

# Build the app
Write-Host "🔨 Building Next.js app..." -ForegroundColor Yellow
npm run build

# Login and deploy
Write-Host "🚀 Deploying to Azure..." -ForegroundColor Yellow

if ($Subscription) {
    swa deploy ./out --app-name $AppName --resource-group $ResourceGroup --subscription-id $Subscription
} else {
    swa deploy ./out --app-name $AppName --resource-group $ResourceGroup
}

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "Check Azure Portal for your app URL and configure environment variables." -ForegroundColor Yellow
