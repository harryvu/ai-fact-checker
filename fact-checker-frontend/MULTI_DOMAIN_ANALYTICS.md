# Multi-Domain Google Analytics Setup

This guide explains how to set up Google Analytics to track both your development and production environments.

## 🌐 **Current Configuration**

- **GA4 Property ID**: `G-CR3YQ1W8D0`
- **Development**: `http://localhost:3000` 
- **Production**: `https://www.wefactcheck.org`

## 📊 **Setting Up Multiple Data Streams**

### Step 1: Access Your GA4 Property
1. Go to [analytics.google.com](https://analytics.google.com)
2. Select your property (`G-CR3YQ1W8D0`)

### Step 2: Add Production Data Stream
1. Navigate to **Admin** → **Property** → **Data Streams**
2. Click **"Add stream"** → **"Web"**
3. Configure:
   ```
   Website URL: https://www.wefactcheck.org
   Stream name: WeFact Check - Production
   Enhanced measurement: ✅ Enable all
   ```
4. Click **"Create stream"**

### Step 3: Add Development Data Stream  
1. Click **"Add stream"** → **"Web"** again
2. Configure:
   ```
   Website URL: http://localhost:3000
   Stream name: WeFact Check - Development  
   Enhanced measurement: ✅ Enable all
   ```
3. Click **"Create stream"**

## 🔧 **Environment Configuration**

Both environments use the **same measurement ID** but different stream configurations:

### Development (.env.local)
```bash
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-CR3YQ1W8D0
NEXTAUTH_URL=http://localhost:3000
```

### Production (.env.production)  
```bash
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-CR3YQ1W8D0
NEXTAUTH_URL=https://www.wefactcheck.org
```

## 📈 **Benefits of Multiple Streams**

1. **Separate Reporting**: View development vs production traffic separately
2. **Filter Options**: Exclude development traffic from production reports  
3. **Testing Isolation**: Test analytics changes without affecting production data
4. **Environment Comparison**: Compare user behavior across environments

## 🎯 **Filtering Data in Reports**

### View Only Production Data
1. Go to any report in GA4
2. Click **"Add filter"** 
3. Select **"Hostname"** → **"exactly matches"** → `www.wefactcheck.org`

### View Only Development Data  
1. Add filter: **"Hostname"** → **"exactly matches"** → `localhost`

### Exclude Development from All Reports
1. Go to **Admin** → **Property** → **Data Settings** → **Data Filters**
2. Create filter:
   ```
   Filter Name: Exclude Development
   Filter Type: Exclude
   Hostname: localhost
   ```

## 🛠️ **Deployment Steps**

### For Local Development
Your current setup is ready! Just run:
```bash
npm run dev
```

### For Production Deployment
1. **GitHub Secrets**: Add `NEXT_PUBLIC_GA_MEASUREMENT_ID=G-CR3YQ1W8D0`
2. **Deploy**: Your CI/CD will use the production environment file
3. **Verify**: Check Real-time reports for both domains

## 📊 **Monitoring Both Environments**

### Real-time View
- **Production traffic**: Shows as `www.wefactcheck.org`  
- **Development traffic**: Shows as `localhost:3000`

### Custom Dashboard
Create segments for:
- Production users only
- Development testing only  
- Combined analytics

## 🔒 **Security Considerations**

- ✅ **Same GA ID**: Uses one measurement ID for both environments
- ✅ **Domain filtering**: Can separate data by hostname
- ✅ **Privacy compliance**: Same privacy notice on both domains
- ✅ **No sensitive data**: Only usage patterns tracked

## 🚀 **Next Steps**

1. **Set up data streams** in GA4 (follow steps above)
2. **Deploy to production** with updated environment variables
3. **Test both environments** to verify tracking
4. **Create filtered views** for cleaner reporting
5. **Set up alerts** for production traffic patterns

Your analytics will now track both development testing and real user behavior separately while using the same GA4 property! 📈
