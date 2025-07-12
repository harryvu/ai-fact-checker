# Test Azure Static Web App Deployment
# This script tests the deployed application

param(
    [Parameter(Mandatory=$false)]
    [string]$AppUrl
)

if (-not $AppUrl) {
    # Try to read from deployment info
    if (Test-Path "azure-deployment-info.json") {
        $deploymentInfo = Get-Content "azure-deployment-info.json" | ConvertFrom-Json
        $AppUrl = $deploymentInfo.URL
    } else {
        $AppUrl = Read-Host "Enter your Static Web App URL (e.g., https://your-app.azurestaticapps.net)"
    }
}

Write-Host "🧪 Testing Azure Static Web App Deployment" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Testing URL: $AppUrl" -ForegroundColor Cyan

# Test 1: Basic connectivity
Write-Host "`n1. Testing basic connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $AppUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ App is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "⚠️  App responded with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Failed to connect to app: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check if it's a Next.js app
Write-Host "`n2. Testing Next.js app detection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $AppUrl -Method GET -UseBasicParsing
    if ($response.Content -match "next" -or $response.Content -match "Next.js") {
        Write-Host "✅ Next.js app detected" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Next.js markers not found in response" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Failed to analyze app content" -ForegroundColor Red
}

# Test 3: Check auth endpoints
Write-Host "`n3. Testing authentication endpoints..." -ForegroundColor Yellow
$authEndpoints = @(
    "/api/auth/providers",
    "/api/auth/session",
    "/api/auth/csrf"
)

foreach ($endpoint in $authEndpoints) {
    try {
        $response = Invoke-WebRequest -Uri "$AppUrl$endpoint" -Method GET -UseBasicParsing
        Write-Host "✅ $endpoint - Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  $endpoint - Failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Test 4: Check API proxy endpoint
Write-Host "`n4. Testing API proxy endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$AppUrl/api/fact-check" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 405) {
        Write-Host "✅ API proxy endpoint exists (405 Method Not Allowed is expected for GET)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API proxy endpoint - Status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  API proxy endpoint test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 5: Performance check
Write-Host "`n5. Testing performance..." -ForegroundColor Yellow
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $AppUrl -Method GET -UseBasicParsing
    $stopwatch.Stop()
    $loadTime = $stopwatch.ElapsedMilliseconds
    
    if ($loadTime -lt 2000) {
        Write-Host "✅ Good performance - Load time: $loadTime ms" -ForegroundColor Green
    } elseif ($loadTime -lt 5000) {
        Write-Host "⚠️  Moderate performance - Load time: $loadTime ms" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  Slow performance - Load time: $loadTime ms" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Performance test failed" -ForegroundColor Red
}

Write-Host "`n🎯 Manual Testing Checklist:" -ForegroundColor Yellow
Write-Host "□ Open the app in your browser" -ForegroundColor White
Write-Host "□ Test Google sign-in" -ForegroundColor White
Write-Host "□ Test fact-checking functionality" -ForegroundColor White
Write-Host "□ Check browser console for errors" -ForegroundColor White
Write-Host "□ Test on mobile devices" -ForegroundColor White
Write-Host "□ Verify all images load correctly" -ForegroundColor White

Write-Host "`n🌐 App URL: $AppUrl" -ForegroundColor Cyan
Write-Host "📋 Test completed!" -ForegroundColor Green

# Offer to open the app
$openApp = Read-Host "`nWould you like to open the app in your browser? (y/n)"
if ($openApp -eq 'y' -or $openApp -eq 'Y') {
    Start-Process $AppUrl
}
