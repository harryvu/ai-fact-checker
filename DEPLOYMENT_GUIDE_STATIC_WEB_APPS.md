# Deployment Guide for Fact Checker App

This guide covers multiple ways to deploy your Next.js fact-checker app to Azure Static Web Apps.

## Prerequisites

- Azure CLI installed and configured
- Node.js 18 or later
- Azure subscription
- GitHub repository (for automated deployment)

## Deployment Options

### Option 1: PowerShell Script (Recommended for first-time deployment)

Use the comprehensive PowerShell script for a guided deployment:

```powershell
# Navigate to the frontend directory
cd fact-checker-frontend

# Run the deployment script
.\deploy-static-web-app.ps1 -ResourceGroupName "rg-fact-checker" -StaticWebAppName "fact-checker-app"
```

#### Script Parameters:
- `ResourceGroupName` (required): Azure resource group name
- `StaticWebAppName` (required): Name for your Static Web App
- `Location` (optional): Azure region (default: eastus2)
- `GitHubRepo` (optional): GitHub repository URL for automated deployments
- `GitHubBranch` (optional): Branch to deploy from (default: main)
- `GitHubToken` (optional): GitHub personal access token

### Option 2: Simple SWA CLI Deployment

For quick deployments using the Static Web Apps CLI:

```powershell
# Navigate to the frontend directory
cd fact-checker-frontend

# Run the simple deployment script
.\deploy-simple.ps1 -AppName "fact-checker-app" -ResourceGroup "rg-fact-checker"
```

### Option 3: GitHub Actions (Automated)

The repository already includes a GitHub Actions workflow (`.github/workflows/azure-static-web-apps.yml`) for automated deployments.

#### Setup Steps:

1. **Create a Static Web App in Azure Portal:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Create new Static Web App
   - Choose "Other" as source
   - Note the deployment token

2. **Configure GitHub Secrets:**
   Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:
   
   ```
   AZURE_STATIC_WEB_APPS_API_TOKEN=<deployment-token-from-azure>
   NEXT_PUBLIC_API_URL=https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function
   NEXTAUTH_URL=https://your-app-domain.azurestaticapps.net
   NEXTAUTH_SECRET=swCVVFKs4k85L3cUBsXUOf6tBCTBnxlp
   GOOGLE_CLIENT_ID=83488169129-ar1m5s6jtcg1tsop6746ndrih40s1qfv.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=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
   FACEBOOK_CLIENT_ID=your-facebook-client-id
   FACEBOOK_CLIENT_SECRET=your-facebook-client-secret
   ```

3. **Push to main branch** to trigger automatic deployment

### Option 4: Manual Azure CLI

For manual deployment using Azure CLI:

```powershell
# Login to Azure
az login

# Create resource group
az group create --name rg-fact-checker --location eastus2

# Build the app
cd fact-checker-frontend
npm install
npm run build

# Create Static Web App
az staticwebapp create --name fact-checker-app --resource-group rg-fact-checker --location eastus2

# Get deployment token
$token = az staticwebapp secrets list --name fact-checker-app --resource-group rg-fact-checker --query "properties.apiKey" -o tsv

# Deploy using SWA CLI
npx @azure/static-web-apps-cli deploy ./out --deployment-token $token
```

## Post-Deployment Configuration

After deployment, you'll need to:

### 1. Configure Environment Variables in Azure

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your Static Web App
3. Go to **Configuration** in the left menu
4. Add the following environment variables:

```
NEXTAUTH_URL=https://your-actual-app-url.azurestaticapps.net
NEXTAUTH_SECRET=swCVVFKs4k85L3cUBsXUOf6tBCTBnxlp
NEXT_PUBLIC_API_URL=https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function
GOOGLE_CLIENT_ID=83488169129-ar1m5s6jtcg1tsop6746ndrih40s1qfv.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=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
```

### 2. Update OAuth Provider Settings

#### Google OAuth:
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to APIs & Services → Credentials
3. Edit your OAuth 2.0 Client ID
4. Add to **Authorized redirect URIs**:
   ```
   https://your-app-url.azurestaticapps.net/api/auth/callback/google
   ```

#### Facebook OAuth (if enabled):
1. Go to [Facebook Developers](https://developers.facebook.com)
2. Navigate to your app → Facebook Login → Settings
3. Add to **Valid OAuth Redirect URIs**:
   ```
   https://your-app-url.azurestaticapps.net/api/auth/callback/facebook
   ```

### 3. Test the Deployment

1. Visit your deployed app URL
2. Test Google OAuth sign-in
3. Test the fact-checking functionality
4. Verify all features work as expected

## Environment Variables Reference

Your `.env.production` file serves as a reference for the environment variables that need to be configured in Azure:

- `NEXTAUTH_URL`: Your actual Static Web App URL
- `NEXTAUTH_SECRET`: Secure random string for NextAuth.js
- `NEXT_PUBLIC_API_URL`: Your Azure Functions backend URL
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth client secret
- `FACEBOOK_CLIENT_ID`: Facebook app ID (optional)
- `FACEBOOK_CLIENT_SECRET`: Facebook app secret (optional)

## Troubleshooting

### Common Issues:

1. **OAuth redirect mismatch**: Ensure OAuth provider redirect URIs match your deployed domain
2. **Environment variables not applied**: Check that they're configured in Azure Portal, not just in `.env.production`
3. **Build failures**: Ensure all dependencies are installed and the app builds locally
4. **API calls failing**: Verify CORS settings on your Azure Functions backend

### Getting Help:

- Check Azure Portal logs in your Static Web App
- Review GitHub Actions logs for automated deployments
- Test locally with production environment variables

## Next Steps

After successful deployment:
1. Set up monitoring and alerts in Azure
2. Configure custom domain (optional)
3. Set up staging environments for testing
4. Implement CI/CD pipeline improvements
