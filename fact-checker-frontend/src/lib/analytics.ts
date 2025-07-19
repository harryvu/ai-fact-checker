// Google Analytics tracking utilities

type GtagCommand = 'config' | 'event' | 'js' | 'set'
type GtagConfigParams = {
  page_path?: string
  page_title?: string
  page_location?: string
}
type GtagEventParams = Record<string, string | number | boolean>

declare global {
  interface Window {
    gtag: (command: GtagCommand, targetId: string, parameters?: GtagConfigParams | GtagEventParams) => void
    dataLayer: unknown[]
  }
}

export const GA_MEASUREMENT_ID = process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID

// Track page views
export const pageview = (url: string) => {
  if (typeof window.gtag !== 'undefined' && GA_MEASUREMENT_ID) {
    window.gtag('config', GA_MEASUREMENT_ID, {
      page_path: url,
    })
  }
}

// Track custom events
export const event = (action: string, parameters?: GtagEventParams) => {
  if (typeof window.gtag !== 'undefined') {
    window.gtag('event', action, parameters)
  }
}

// Specific fact-checking event trackers
export const trackFactCheckRequest = (method: 'text' | 'url', model: string, contentLength?: number) => {
  event('fact_check_request', {
    method,
    model,
    ...(contentLength !== undefined && { content_length: contentLength }),
    event_category: 'fact_checking',
  })
}

export const trackFactCheckSuccess = (rating: string, claimsCount: number, processingTime?: number) => {
  event('fact_check_success', {
    rating,
    claims_count: claimsCount,
    ...(processingTime !== undefined && { processing_time: processingTime }),
    event_category: 'fact_checking',
  })
}

export const trackFactCheckError = (errorType: string) => {
  event('fact_check_error', {
    error_type: errorType,
    event_category: 'fact_checking',
  })
}

export const trackUserEngagement = (action: string, details?: GtagEventParams) => {
  event('user_engagement', {
    engagement_action: action,
    ...details,
    event_category: 'user_interaction',
  })
}
