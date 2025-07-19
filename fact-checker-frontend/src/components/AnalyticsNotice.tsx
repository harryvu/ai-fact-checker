'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { X, Info } from 'lucide-react'

export default function AnalyticsNotice() {
  const [isVisible, setIsVisible] = useState(false) // Start with false to prevent SSR mismatch
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    // This runs only on the client after hydration
    setIsClient(true)
    const dismissed = localStorage.getItem('analytics-notice-dismissed')
    if (!dismissed && process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID) {
      setIsVisible(true)
    }
  }, [])

  const dismissNotice = () => {
    setIsVisible(false)
    localStorage.setItem('analytics-notice-dismissed', 'true')
  }

  // Don't render anything until client-side hydration is complete
  if (!isClient || !isVisible) {
    return null
  }

  return (
    <Card className="fixed bottom-4 right-4 max-w-sm bg-blue-50 border-blue-200 shadow-lg z-50">
      <CardContent className="p-4">
        <div className="flex items-start gap-3">
          <Info className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="text-sm text-blue-800 mb-2">
              We use analytics to improve your experience. No personal data is collected.
            </p>
            <Button
              onClick={dismissNotice}
              size="sm"
              variant="outline"
              className="text-blue-700 border-blue-300 hover:bg-blue-100"
            >
              Got it
            </Button>
          </div>
          <Button
            onClick={dismissNotice}
            size="sm"
            variant="ghost"
            className="p-1 h-auto text-blue-600 hover:bg-blue-100"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
