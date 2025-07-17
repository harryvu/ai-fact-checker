'use client'

import { useState } from 'react'
// import { useSession, signIn } from 'next-auth/react'  // Disabled for static deployment
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Loader2, ExternalLink, CheckCircle, XCircle, AlertCircle } from 'lucide-react'
import { factCheckTextStream } from '@/lib/api'
import { FactCheckResponse } from '@/lib/types'

export default function FactChecker() {
  // Temporarily disable authentication for static deployment
  const session = { user: { id: 'anonymous', email: 'anonymous@example.com' } }
  
  const [inputText, setInputText] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [streamingResult, setStreamingResult] = useState('')
  const [result, setResult] = useState<FactCheckResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  // Authentication is disabled for static deployment
  // Show sign-in prompt if not authenticated
  /*
  if (!session) {
    return (
      <div className="max-w-4xl mx-auto p-6 space-y-6">
        <Card className="border-blue-200 bg-blue-50">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-blue-800">
              <Lock className="h-6 w-6" />
              Authentication Required
            </CardTitle>
            <CardDescription className="text-blue-600">
              You must sign in to use the AI Fact Checker
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-center space-y-4">
              <p className="text-blue-700">
                Please sign in with your Google account to verify information using our AI-powered fact-checking tool.
              </p>
              <Button
                onClick={() => {}} // signIn() disabled for static deployment
                className="flex items-center gap-2"
              >
                <LogIn className="h-4 w-4" />
                Sign In to Continue
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }
  */

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!inputText.trim()) {
      setError('Please enter some text to fact-check')
      return
    }

    setIsLoading(true)
    setError(null)
    setResult(null)
    setStreamingResult('')

    try {
      const response = await factCheckTextStream(
        inputText,
        session?.user?.email || 'anonymous',
        (chunk) => {
          setStreamingResult(prev => prev + chunk)
        }
      )
      
      setResult(response)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred')
    } finally {
      setIsLoading(false)
    }
  }

  const getResultIcon = (result: string) => {
    const lowerResult = result.toLowerCase()
    if (lowerResult.includes('true') || lowerResult.includes('accurate')) {
      return <CheckCircle className="h-5 w-5 text-green-600" />
    }
    if (lowerResult.includes('false') || lowerResult.includes('inaccurate')) {
      return <XCircle className="h-5 w-5 text-red-600" />
    }
    return <AlertCircle className="h-5 w-5 text-yellow-600" />
  }

  const getResultColor = (result: string) => {
    const lowerResult = result.toLowerCase()
    if (lowerResult.includes('true') || lowerResult.includes('accurate')) {
      return 'bg-green-50 border-green-200'
    }
    if (lowerResult.includes('false') || lowerResult.includes('inaccurate')) {
      return 'bg-red-50 border-red-200'
    }
    return 'bg-yellow-50 border-yellow-200'
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CheckCircle className="h-6 w-6" />
            Fact Checker
          </CardTitle>
          <CardDescription>
            Enter text to verify its accuracy using AI-powered fact-checking
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="fact-text" className="block text-sm font-medium mb-2">
                Text to Fact-Check
              </label>
              <Textarea
                id="fact-text"
                placeholder="Enter the text you want to fact-check..."
                value={inputText}
                onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setInputText(e.target.value)}
                className="min-h-[100px]"
                disabled={isLoading}
              />
            </div>
            <Button type="submit" disabled={isLoading || !inputText.trim()}>
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Fact-checking...
                </>
              ) : (
                'Fact-Check'
              )}
            </Button>
          </form>
        </CardContent>
      </Card>

      {error && (
        <Card className="border-red-200 bg-red-50">
          <CardContent className="pt-6">
            <div className="flex items-center gap-2 text-red-700">
              <XCircle className="h-5 w-5" />
              <span>{error}</span>
            </div>
          </CardContent>
        </Card>
      )}

      {isLoading && streamingResult && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Loader2 className="h-5 w-5 animate-spin" />
              Streaming Result
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="whitespace-pre-wrap text-sm bg-gray-50 p-4 rounded-lg">
              {streamingResult}
            </div>
          </CardContent>
        </Card>
      )}

      {result && (
        <Card className={getResultColor(result.overall_rating)}>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              {getResultIcon(result.overall_rating)}
              Fact-Check Result
            </CardTitle>
            <CardDescription>
              Overall Rating: {result.overall_rating}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <h4 className="font-semibold mb-2">Summary:</h4>
              <p className="text-sm bg-white p-3 rounded border">
                {result.summary}
              </p>
            </div>

            {result.claims && result.claims.length > 0 && (
              <div>
                <h4 className="font-semibold mb-3">Claims Analysis:</h4>
                <div className="grid gap-3">
                  {result.claims.map((claim, index) => (
                    <Card key={index} className="bg-white">
                      <CardContent className="pt-4">
                        <div className="space-y-2">
                          <div className="flex items-start justify-between gap-3">
                            <div className="flex-1">
                              <h5 className="font-medium text-sm mb-1">
                                {claim.claim}
                              </h5>
                              <Badge variant="outline" className="text-xs mb-2">
                                {claim.rating}
                              </Badge>
                              <p className="text-xs text-gray-600 mb-2">
                                {claim.explanation}
                              </p>
                              {claim.sources && claim.sources.length > 0 && (
                                <div className="text-xs">
                                  <span className="font-medium">Sources:</span>
                                  <ul className="mt-1 space-y-1">
                                    {claim.sources.map((source, sourceIndex) => (
                                      <li key={sourceIndex}>
                                        <a
                                          href={source}
                                          target="_blank"
                                          rel="noopener noreferrer"
                                          className="text-blue-600 hover:text-blue-800 inline-flex items-center gap-1"
                                        >
                                          <ExternalLink className="h-3 w-3" />
                                          {source}
                                        </a>
                                      </li>
                                    ))}
                                  </ul>
                                </div>
                              )}
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </div>
            )}

            {result.citations && result.citations.length > 0 && (
              <div>
                <h4 className="font-semibold mb-3">Citations:</h4>
                <div className="grid gap-2">
                  {result.citations.map((citation, index) => (
                    <a
                      key={index}
                      href={citation}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-xs text-blue-600 hover:text-blue-800 inline-flex items-start gap-1 break-all overflow-hidden"
                    >
                      <ExternalLink className="h-3 w-3 flex-shrink-0 mt-0.5" />
                      <span className="break-all overflow-wrap-anywhere">{citation}</span>
                    </a>
                  ))}
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
