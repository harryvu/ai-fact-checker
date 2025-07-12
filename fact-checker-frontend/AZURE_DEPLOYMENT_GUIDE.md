# Azure Static Web Apps Deployment Guide

This guide will help you deploy your Next.js fact-checker frontend to Azure Static Web Apps.

## Prerequisites

1. **Azure CLI** - Install from https://aka.ms/installazurecliwindows
2. **Azure Account** - Sign up at https://azure.microsoft.com/free/
3. **GitHub Account** - For repository and CI/CD
4. **Git** - For version control

## Deployment Options

### Option 1: Automated Deployment with GitHub Actions (Recommended)

This is the easiest and most robust option that provides CI/CD.

#### Steps:

1. **Push your code to GitHub**
   ```bash
   git add .
   git commit -m "Prepare for Azure deployment"
   git push origin main
   ```

2. **Create Azure Static Web App**
   ```powershell
   # Login to Azure
   az login
   
   # Run the deployment script
   .\azure-deploy.ps1 -ResourceGroupName "rg-fact-checker" -StaticWebAppName "fact-checker-app"
   ```

3. **Configure GitHub Secrets**
   - Go to your GitHub repository
   - Navigate to Settings > Secrets and variables > Actions
   - Add the following secrets:
     - `AZURE_STATIC_WEB_APPS_API_TOKEN` (from azure-deployment-info.json)
     - `NEXT_PUBLIC_API_URL` (your Azure Function URL)
     - `NEXTAUTH_URL` (your Static Web App URL)
     - `NEXTAUTH_SECRET` (your auth secret)
     - `GOOGLE_CLIENT_ID` (your Google OAuth client ID)
     - `GOOGLE_CLIENT_SECRET` (your Google OAuth client secret)
     - `FACEBOOK_CLIENT_ID` (optional)
     - `FACEBOOK_CLIENT_SECRET` (optional)

4. **Configure OAuth Redirect URIs**
   - **Google Cloud Console**: Add `https://your-app-name.azurestaticapps.net/api/auth/callback/google`
   - **Facebook Developer Console**: Add `https://your-app-name.azurestaticapps.net/api/auth/callback/facebook`

5. **Deploy**
   - Push any changes to trigger deployment
   - GitHub Actions will automatically build and deploy your app

### Option 2: Manual Deployment with Azure CLI

If you prefer manual deployment:

1. **Build the application**
   ```powershell
   cd fact-checker-frontend
   npm run build
   ```

2. **Deploy to Azure Static Web Apps**
   ```powershell
   az staticwebapp create \
     --name "fact-checker-app" \
     --resource-group "rg-fact-checker" \
     --location "East US 2" \
     --source . \
     --branch main \
     --app-location "/" \
     --output-location "out"
   ```

## Environment Variables

### Development (.env.local)
```bash
NEXT_PUBLIC_API_URL=https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### Production (GitHub Secrets)
```bash
NEXT_PUBLIC_API_URL=https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function
NEXTAUTH_URL=https://your-app-name.azurestaticapps.net
NEXTAUTH_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

## Post-Deployment Checklist

- [ ] Verify the app loads at your Static Web App URL
- [ ] Test sign-in with Google
- [ ] Test fact-checking functionality
- [ ] Verify API calls to your Azure Function backend
- [ ] Check browser console for any errors
- [ ] Test on mobile devices

## Troubleshooting

### Common Issues:

1. **OAuth Redirect URI Mismatch**
   - Ensure redirect URIs in Google/Facebook console match your deployed URL
   - Format: `https://your-app.azurestaticapps.net/api/auth/callback/google`

2. **API Connection Issues**
   - Verify `NEXT_PUBLIC_API_URL` points to your Azure Function
   - Check CORS settings on your Azure Function
   - Ensure your Azure Function is running

3. **Build Failures**
   - Check GitHub Actions logs for build errors
   - Verify all environment variables are set in GitHub secrets
   - Ensure `next.config.ts` is properly configured

4. **Authentication Issues**
   - Verify `NEXTAUTH_URL` matches your deployed domain
   - Check `NEXTAUTH_SECRET` is set and secure
   - Ensure OAuth credentials are valid

## Monitoring and Maintenance

1. **Monitor via Azure Portal**
   - View deployment logs
   - Check resource usage
   - Monitor performance

2. **GitHub Actions**
   - Monitor deployment status
   - Review build logs
   - Set up notifications for failed deployments

3. **Application Insights** (Optional)
   - Add Application Insights for detailed monitoring
   - Track user interactions and errors

## Costs

- **Azure Static Web Apps**: Free tier available (100 GB bandwidth, 0.5 GB storage)
- **Upgrade to Standard**: $9/month for additional features and higher limits

## Next Steps

1. Set up custom domain (optional)
2. Configure SSL certificate
3. Set up staging environments
4. Implement monitoring and alerting
5. Add automated testing in CI/CD pipeline

## Support

For issues with this deployment:
1. Check the troubleshooting section above
2. Review Azure Static Web Apps documentation
3. Check GitHub Actions logs
4. Verify all environment variables and secrets
