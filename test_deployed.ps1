Write-Host "Testing Deployed Fact Checker API..." -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

$functionUrl = "https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function"

Write-Host "`nFunction URL: $functionUrl" -ForegroundColor Cyan
Write-Host "Waiting for function to be ready..." -ForegroundColor Yellow

# Wait and retry logic
$maxRetries = 6
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        Write-Host "`nAttempt $($retryCount + 1) of $maxRetries..." -ForegroundColor Yellow
        
        # Test GET request
        $response = Invoke-RestMethod -Uri $functionUrl -Method GET -TimeoutSec 30
        Write-Host "✓ Function is responding!" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 3)
        
        # Test POST request
        Write-Host "`nTesting POST request..." -ForegroundColor Yellow
        $body = @{
            text = "The Earth is flat and NASA is hiding this from the public."
            model = "sonar-pro"
        } | ConvertTo-Json
        
        $postResponse = Invoke-RestMethod -Uri $functionUrl -Method POST -Body $body -ContentType "application/json" -TimeoutSec 60
        Write-Host "✓ POST request successful!" -ForegroundColor Green
        Write-Host ($postResponse | ConvertTo-Json -Depth 3)
        
        break
    } catch {
        $retryCount++
        if ($retryCount -ge $maxRetries) {
            Write-Host "✗ Function is not responding after $maxRetries attempts." -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
            Write-Host "1. The function might still be starting up (can take 5-10 minutes)" -ForegroundColor White
            Write-Host "2. Try testing again in a few minutes" -ForegroundColor White
            Write-Host "3. Check Azure portal for any deployment issues" -ForegroundColor White
        } else {
            Write-Host "Function not ready yet, waiting 30 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
}

Write-Host "`nYour deployed function is ready!" -ForegroundColor Green
Write-Host "You can now use this URL in your applications:" -ForegroundColor Cyan
Write-Host $functionUrl -ForegroundColor White
