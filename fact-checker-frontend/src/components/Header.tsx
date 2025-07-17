'use client'

// import { useSession, signIn, signOut } from 'next-auth/react'  // Disabled for static deployment
import { Button } from '@/components/ui/button'
import { User, LogOut, LogIn } from 'lucide-react'
// import Image from 'next/image'  // Not needed for static deployment

export default function Header() {
  // Disable authentication for static deployment
  const session = { user: { name: 'Anonymous User', email: 'anonymous@example.com' } }

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="container flex h-16 items-center justify-between max-w-6xl mx-auto px-4">
        <div className="flex items-center gap-2">
          <h1 className="text-xl font-bold">Fact Checker</h1>
        </div>
        
        <div className="flex items-center gap-4">
          {session ? (
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 bg-gray-200 rounded-full flex items-center justify-center">
                  <User className="h-4 w-4 text-gray-500" />
                </div>
                <span className="text-sm font-medium hidden sm:inline-block">
                  {session.user?.name || session.user?.email}
                </span>
              </div>
              <Button
                onClick={() => {}} // signOut disabled for static deployment
                variant="outline"
                size="sm"
                className="flex items-center gap-2"
                disabled
              >
                <LogOut className="h-4 w-4" />
                Sign out
              </Button>
            </div>
          ) : (
            <Button
              onClick={() => {}} // signIn disabled for static deployment
              className="flex items-center gap-2"
              disabled
            >
              <LogIn className="h-4 w-4" />
              Sign in
            </Button>
          )}
        </div>
      </div>
    </header>
  )
}
