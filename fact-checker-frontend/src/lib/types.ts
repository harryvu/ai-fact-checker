export interface FactCheckRequest {
  text: string
  userId?: string
}

export interface Claim {
  claim: string
  rating: string
  explanation: string
  sources: string[]
}

export interface FactCheckResponse {
  overall_rating: string
  summary: string
  claims: Claim[]
  citations?: string[]
}

export interface Source {
  title: string
  url: string
  snippet: string
}

export interface User {
  id: string
  name?: string | null
  email?: string | null
  image?: string | null
}

export interface FactCheckHistory {
  id: string
  text: string
  result: string
  sources: Source[]
  timestamp: Date
  userId: string
}
