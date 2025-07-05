# Fact Checker Azure Functions

A serverless fact-checking API built with Azure Functions that uses Perplexity's Sonar API to identify false or misleading claims in articles or statements.

## Features

- HTTP API endpoint for fact-checking text content
- Support for URL-based article analysis
- Multiple Perplexity model options
- Structured and unstructured output formats
- Comprehensive error handling and logging

## Setup

### Prerequisites

- Python 3.9+ (Azure Functions supports Python 3.9, 3.10, 3.11, and 3.12)
- Azure Functions Core Tools
- Azure CLI (for deployment)
- Perplexity API key

**Note**: While Azure Functions in the cloud supports Python 3.9-3.12 with GA status, the local Azure Functions Core Tools may currently require Python 3.6-3.10 for local development. For deployment to Azure, you can use any supported Python version (3.9-3.12).

### Local Development

**Important**: If you encounter Python version compatibility issues with `func start`, you may need to use Python 3.10 or earlier for local development, even though the deployed function can run on Python 3.12 in Azure.

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure API Key:**
   Update `local.settings.json` with your Perplexity API key:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "UseDevelopmentStorage=true",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.12",
       "PPLX_API_KEY": "your_perplexity_api_key_here"
     }
   }
   ```

3. **Run locally:**
   ```bash
   func start
   ```

   The function will be available at: `http://localhost:7071/api/fact_check_function`

## API Usage

### GET Request
Returns API information and usage instructions:
```bash
curl http://localhost:7071/api/fact_check_function
```

### POST Request - Text Analysis
Fact-check direct text input:
```bash
curl -X POST http://localhost:7071/api/fact_check_function \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The Earth is flat and vaccines contain microchips.",
    "model": "sonar-pro",
    "structured_output": true
  }'
```

### POST Request - URL Analysis
Fact-check an article from a URL:
```bash
curl -X POST http://localhost:7071/api/fact_check_function \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article",
    "model": "sonar-pro",
    "structured_output": false
  }'
```

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | string | No* | Direct text to fact-check |
| `url` | string | No* | URL of article to fact-check |
| `model` | string | No | Perplexity model (default: "sonar-pro") |
| `structured_output` | boolean | No | Enable structured JSON output (default: false) |

*Either `text` or `url` is required.

## Response Format

### Successful Response
```json
{
  "overall_rating": "MOSTLY_FALSE",
  "summary": "The content contains multiple false claims...",
  "claims": [
    {
      "claim": "The Earth is flat",
      "rating": "FALSE",
      "explanation": "Scientific evidence overwhelmingly supports that Earth is a sphere...",
      "sources": ["NASA Earth Science Division", "Scientific consensus"]
    }
  ],
  "citations": ["https://example.com/source1", "https://example.com/source2"]
}
```

### Error Response
```json
{
  "error": "Error description here"
}
```

## Deployment to Azure

1. **Create Function App:**
   ```bash
   az functionapp create \
     --resource-group myResourceGroup \
     --consumption-plan-location westus \
     --runtime python \
     --runtime-version 3.9 \
     --functions-version 4 \
     --name myFactCheckerApp \
     --storage-account mystorageaccount
   ```

2. **Set environment variables:**
   ```bash
   az functionapp config appsettings set \
     --name myFactCheckerApp \
     --resource-group myResourceGroup \
     --settings "PPLX_API_KEY=your_perplexity_api_key_here"
   ```

3. **Deploy the function:**
   ```bash
   func azure functionapp publish myFactCheckerApp
   ```

## Troubleshooting

### Python Version Issues with Local Development

If you encounter the error "Python 3.6.x to 3.10.x is required" when running `func start`:

1. **Check available Python versions:**
   ```bash
   py --list
   ```

2. **Create a virtual environment with Python 3.10 (if available):**
   ```bash
   py -3.10 -m venv venv310
   venv310\Scripts\activate
   pip install -r requirements.txt
   func start
   ```

3. **Alternative: Install Python 3.10 specifically for local development:**
   - Download Python 3.10 from [python.org](https://www.python.org/downloads/)
   - Use it for local development while keeping Python 3.12 for production deployments

4. **For deployment to Azure:** The function will run on Python 3.12 in the cloud regardless of your local development environment.

### Common Issues

- **Missing API Key**: Ensure `PPLX_API_KEY` is set in `local.settings.json`
- **Network Issues**: Check your internet connection for API calls
- **Module Import Errors**: Run `pip install -r requirements.txt` to ensure all dependencies are installed

## Available Models

- `sonar` - Fast, efficient model
- `sonar-pro` - Higher quality responses (default)
- `sonar-reasoning` - Advanced reasoning capabilities
- `sonar-reasoning-pro` - Highest quality with advanced reasoning

## Rate Limits

Rate limits depend on your Perplexity API subscription tier. The function includes appropriate error handling for rate limit responses.

## Security

- API key is stored securely in Azure Function App Settings
- Function uses "function" level authorization (can be changed in `function.json`)
- Input validation and sanitization included
- Timeout protection for external requests

## Monitoring

- Built-in Azure Functions logging
- Application Insights integration available
- Custom logging for debugging and monitoring

## Error Handling

The API handles various error scenarios:
- Invalid JSON requests
- Missing required parameters
- API key issues
- Network timeouts
- Invalid URLs
- Content extraction failures

## Original CLI Tool

The original CLI version (`fact_checker.py`) is still available for command-line usage. See the file comments for usage instructions.
