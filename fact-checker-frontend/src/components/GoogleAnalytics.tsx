'use client'

import { useEffect, useState } from 'react'
import Script from 'next/script'

interface GoogleAnalyticsProps {
  measurementId: string
}

export default function GoogleAnalytics({ measurementId }: GoogleAnalyticsProps) {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (!measurementId || !isClient) {
    return null
  }

  return (
    <>
      <Script
        src={`https://www.googletagmanager.com/gtag/js?id=${measurementId}`}
        strategy="afterInteractive"
      />
      <Script id="google-analytics" strategy="afterInteractive">
        {`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${measurementId}', {
            page_title: document.title,
            page_location: window.location.href,
            custom_map: {
              'custom_parameter_1': 'environment'
            }
          });
          
          // Track environment for easier filtering
          gtag('event', 'page_view', {
            environment: window.location.hostname === 'localhost' ? 'development' : 'production',
            hostname: window.location.hostname
          });
        `}
      </Script>
    </>
  )
}
