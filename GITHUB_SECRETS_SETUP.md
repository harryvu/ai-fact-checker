# GitHub Secrets Setup Guide for AI Fact Checker

## Required GitHub Secrets

Go to https://github.com/harryvu/ai-fact-checker/settings/secrets/actions and add these secrets:

### 1. AZURE_STATIC_WEB_APPS_API_TOKEN
**Value:** `a3e57002f5495b723a0155abfe658d87cc7e9f4570ece884e3f6f91260bdbb0a01-a0332ffcf-c8e5-4957-b454-0ff36faf9fb500f11280dc251f0f`

### 2. NEXT_PUBLIC_API_URL
**Value:** `https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function`

### 3. NEXTAUTH_URL
**Value:** `https://salmon-moss-0dc251f0f.1.azurestaticapps.net`

### 4. NEXTAUTH_SECRET
**Value:** `swCVVFKs4k85L3cUBsXUOf6tBCTBnxlp`

### 5. GOOGLE_CLIENT_ID
**Value:** `83488169129-ar1m5s6jtcg1tsop6746ndrih40s1qfv.apps.googleusercontent.com`

### 6. GOOGLE_CLIENT_SECRET
**Value:** `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`

### 7. FACEBOOK_CLIENT_ID (optional)
**Value:** `your-facebook-client-id`

### 8. FACEBOOK_CLIENT_SECRET (optional)
**Value:** `your-facebook-client-secret`

## Your Static Web App Details

- **Name:** ai-fact-checker
- **Resource Group:** rg-fact-checker
- **URL:** https://salmon-moss-0dc251f0f.1.azurestaticapps.net
- **Location:** East US 2

## Next Steps

1. Add all the secrets above to your GitHub repository
2. Push any change to the main branch to trigger deployment
3. Check the Actions tab to see the deployment progress
4. Update Google OAuth redirect URIs to include the new domain
