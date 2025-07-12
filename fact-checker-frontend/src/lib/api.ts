import { FactCheckResponse } from '@/lib/types'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function'
const PROXY_URL = '/api/fact-check'

// Debug logging
console.log('API_URL:', API_URL)
console.log('NEXT_PUBLIC_API_URL:', process.env.NEXT_PUBLIC_API_URL)
console.log('Using proxy URL:', PROXY_URL)

export async function factCheckText(text: string, userId?: string): Promise<FactCheckResponse> {
  try {
    const response = await fetch(PROXY_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text,
        user_id: userId,
      }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Error fact-checking text:', error)
    throw new Error('Failed to fact-check text. Please try again.')
  }
}

export async function factCheckTextStream(
  text: string,
  userId?: string,
  onChunk?: (chunk: string) => void
): Promise<FactCheckResponse> {
  try {
    console.log('Making API request to:', PROXY_URL)
    console.log('Request body:', { text, user_id: userId })
    
    const response = await fetch(PROXY_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text,
        user_id: userId,
      }),
    })

    console.log('Response status:', response.status)
    console.log('Response headers:', Array.from(response.headers.entries()))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Error response:', errorText)
      throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`)
    }

    const data = await response.json()
    console.log('Response data:', data)
    
    // Simulate streaming by calling onChunk with the complete response
    if (onChunk) {
      onChunk(JSON.stringify(data, null, 2))
    }
    
    return data
  } catch (error) {
    console.error('Error in factCheckTextStream:', error)
    if (error instanceof Error) {
      console.error('Error stack:', error.stack)
    }
    // Fall back to regular API call
    return factCheckText(text, userId)
  }
}
