export default function DebugAuth() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">Auth Debug Info</h1>
      <div className="space-y-4">
        <div>
          <h2 className="font-semibold">Environment Variables:</h2>
          <pre className="bg-gray-100 p-4 rounded">
            {`NEXTAUTH_URL: ${process.env.NEXTAUTH_URL}
GOOGLE_CLIENT_ID: ${process.env.GOOGLE_CLIENT_ID ? 'Set' : 'Not Set'}
GOOGLE_CLIENT_SECRET: ${process.env.GOOGLE_CLIENT_SECRET ? 'Set' : 'Not Set'}
NEXTAUTH_SECRET: ${process.env.NEXTAUTH_SECRET ? 'Set' : 'Not Set'}`}
          </pre>
        </div>
        
        <div>
          <h2 className="font-semibold">NextAuth Endpoints:</h2>
          <ul className="list-disc pl-6">
            <li><a href="/api/auth/providers" target="_blank" rel="noopener noreferrer" className="text-blue-600">Providers</a></li>
            <li><a href="/api/auth/signin" target="_blank" rel="noopener noreferrer" className="text-blue-600">Sign In</a></li>
            <li><a href="/api/auth/session" target="_blank" rel="noopener noreferrer" className="text-blue-600">Session</a></li>
          </ul>
        </div>
      </div>
    </div>
  )
}
