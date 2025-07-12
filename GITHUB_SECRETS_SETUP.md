# GitHub Secrets Setup Guide for AI Fact Checker

## Required GitHub Secrets

Go to https://github.com/harryvu/ai-fact-checker/settings/secrets/actions and **UPDATE** these secrets:

### 1. AZURE_STATIC_WEB_APPS_API_TOKEN (UPDATE THIS!)
**Value:** `2263483a0c96e436bc88c5136b932a809f00e49b2079d753dab2229e29238c81601-337a452a-230e-4c67-a012-3993254ddb3000f1714093b6b90f`

### 2. NEXT_PUBLIC_API_URL
**Value:** `https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function`

### 3. NEXTAUTH_URL (UPDATE THIS!)
**Value:** `https://calm-field-093b6b90f.1.azurestaticapps.net`

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

## Your NEW Static Web App Details

- **Name:** ai-fact-checker-demo
- **Resource Group:** rg-fact-checker
- **URL:** https://calm-field-093b6b90f.1.azurestaticapps.net
- **Location:** East US 2

## URGENT: Update These Secrets Now!

You need to update these two secrets immediately:
1. **AZURE_STATIC_WEB_APPS_API_TOKEN** - with the new token above
2. **NEXTAUTH_URL** - with the new URL above

## Next Steps

1. Update the two secrets above in GitHub
2. Push any change to trigger deployment
3. Check the Actions tab to see the deployment progress
4. Update Google OAuth redirect URIs to include the new domain
