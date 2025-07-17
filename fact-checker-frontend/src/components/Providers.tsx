'use client'

// import { SessionProvider } from 'next-auth/react'  // Disabled for static deployment
import { ReactNode } from 'react'

interface ProvidersProps {
  children: ReactNode
}

export default function Providers({ children }: ProvidersProps) {
  // Disable SessionProvider for static deployment
  return (
    <>
      {children}
    </>
  )
}
