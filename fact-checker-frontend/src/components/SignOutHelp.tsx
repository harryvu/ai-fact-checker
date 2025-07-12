'use client'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { ExternalLink, Info } from 'lucide-react'

export default function SignOutHelp() {
  return (
    <Card className="max-w-md mx-auto mt-8">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Info className="h-5 w-5" />
          Sign Out Information
        </CardTitle>
        <CardDescription>
          Understanding Google OAuth behavior
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="text-sm space-y-2">
          <p>
            When you sign out of this app, you&apos;re only signed out of the Fact Checker application.
            Your Google account session remains active in your browser.
          </p>
          <p>
            To completely sign out of Google and require password re-entry:
          </p>
          <ol className="list-decimal list-inside space-y-1 ml-4">
            <li>Sign out of Google in your browser</li>
            <li>Clear your browser cookies</li>
            <li>Use an incognito/private window</li>
          </ol>
        </div>
        
        <div className="flex flex-col gap-2">
          <Button
            onClick={() => window.open('https://accounts.google.com/signout', '_blank')}
            variant="outline"
            className="flex items-center gap-2"
          >
            <ExternalLink className="h-4 w-4" />
            Sign Out of Google
          </Button>
          
          <Button
            onClick={() => {
              // Clear local storage and session storage
              localStorage.clear()
              sessionStorage.clear()
              // Reload the page
              window.location.reload()
            }}
            variant="outline"
            className="flex items-center gap-2"
          >
            Clear Browser Data
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
