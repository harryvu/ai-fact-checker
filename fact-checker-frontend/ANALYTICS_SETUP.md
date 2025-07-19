# Google Analytics Integration

This document explains the Google Analytics implementation in the Fact Checker frontend.

## Overview

Google Analytics 4 (GA4) has been integrated to track user interactions and usage patterns without collecting personal information.

## What's Tracked

### Page Views
- Automatic page view tracking
- Page titles and locations

### User Interactions
- **Fact-checking requests**: When users submit text for fact-checking
- **User engagement**: Text input focus, typing start, form interactions
- **External link clicks**: When users click on sources or citations
- **Errors**: Failed fact-check requests and their error types

### Custom Events
- `fact_check_request`: Tracks method (text/url), model used, content length
- `fact_check_success`: Tracks result rating, claims count, processing time
- `fact_check_error`: Tracks error types and failure reasons
- `user_engagement`: Tracks various user interactions

## Setup Instructions

### 1. Create Google Analytics Property
1. Go to [Google Analytics](https://analytics.google.com)
2. Create a new GA4 property
3. Get your Measurement ID (format: G-XXXXXXXXXX)

### 2. Configure Environment Variable
Update your `.env.local` file:
```bash
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

### 3. Deploy
The analytics will automatically start tracking once deployed with the measurement ID.

## Privacy Considerations

- **No Personal Data**: Analytics tracks usage patterns, not personal information
- **IP Anonymization**: GA4 anonymizes IP addresses by default
- **Notice**: Users see a dismissible privacy notice about analytics
- **Local Storage**: Notice dismissal is stored locally to avoid repeated notifications

## Analytics Dashboard

Once set up, you can view:
- **Real-time users**: Live user activity
- **User demographics**: Geographic and device information
- **Engagement metrics**: Session duration, page views
- **Custom events**: Fact-checking usage patterns
- **Traffic sources**: How users find your app

## GDPR Compliance

For GDPR compliance, consider:
- Adding a cookie consent banner
- Providing opt-out mechanisms
- Including analytics information in your privacy policy
- Configuring data retention settings in GA4

## Files Modified

- `src/components/GoogleAnalytics.tsx`: GA4 script integration
- `src/lib/analytics.ts`: Analytics tracking utilities
- `src/app/layout.tsx`: Added GA component to app layout
- `src/components/FactChecker.tsx`: Added event tracking
- `src/components/AnalyticsNotice.tsx`: Privacy notice component
- `src/app/page.tsx`: Added analytics notice
- `.env.local`: Added GA measurement ID

## Testing

To test analytics:
1. Set up GA4 property and get measurement ID
2. Add measurement ID to environment variables
3. Run the app locally or deploy
4. Use Google Analytics DebugView for real-time event monitoring
5. Verify events appear in GA4 dashboard (may take 24-48 hours for full data)
