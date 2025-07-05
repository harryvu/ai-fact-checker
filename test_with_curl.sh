#!/bin/bash
# Curl Test Script for Azure Fact Checker API

FUNCTION_URL="https://func-fact-checker-v4-202507031710.azurewebsites.net/api/fact_check_function"

echo "🧪 Testing Azure Fact Checker API with curl..."
echo "=================================================="
echo

# Test 2: POST request with text
echo "2. Testing POST request with text..."
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "text": "The Amazon rainforest produces 20% of the world’s oxygen.",
    "model": "sonar-pro"
  }' \
  -w "\nStatus: %{http_code}\nTime: %{time_total}s\n\n"

# Test 3: POST request with structured output (Method 1 - escaped quotes in single quotes)
echo "3. Testing POST request with structured output..."
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "text": "Musician Paul McCartney once refused to celebrate Pride month, saying \"woke does not deserve remembrance.\"",
    "structured_output": true
  }' \
  -w "\nStatus: %{http_code}\nTime: %{time_total}s\n\n"

echo "✅ Curl testing completed!"
