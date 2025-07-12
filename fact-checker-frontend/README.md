# Fact Checker Frontend

A Next.js TypeScript application that provides a user-friendly interface for the AI-powered fact-checking service.

## Features

- **Simple Form Interface**: Clean and intuitive text input for fact-checking
- **Real-time Streaming**: Live results as the AI processes your text
- **User Authentication**: Sign in with Google and Facebook accounts
- **Source Citations**: Clickable links to verify information sources
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Modern UI**: Built with Tailwind CSS and shadcn/ui components

## Tech Stack

- **Next.js 15**: React framework with App Router
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first CSS framework
- **shadcn/ui**: Beautiful and accessible component library
- **NextAuth.js**: Authentication with OAuth providers
- **Lucide React**: Icon library

## Prerequisites

Before running the application, ensure you have:

- Node.js 18 or higher
- npm or yarn package manager
- OAuth credentials for Google and Facebook (for authentication)

## Installation

1. Navigate to the frontend directory:
```bash
cd fact-checker-frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env.local` file and configure your environment variables:
```env
# Azure Function API
NEXT_PUBLIC_API_URL=https://func-fact-checker-demo.azurewebsites.net/api/fact_check_function

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here-change-in-production

# OAuth Providers
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

FACEBOOK_CLIENT_ID=your-facebook-client-id
FACEBOOK_CLIENT_SECRET=your-facebook-client-secret
```

## OAuth Setup

### Google OAuth
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google+ API
4. Create credentials (OAuth 2.0 Client ID)
5. Add authorized redirect URIs: `http://localhost:3000/api/auth/callback/google`

### Facebook OAuth
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product
4. Configure OAuth redirect URIs: `http://localhost:3000/api/auth/callback/facebook`

## Running the Application

### Development Mode
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Production Build
```bash
npm run build
npm start
```

## API Integration

The application connects to the Azure Function API for fact-checking. Make sure:

1. The Azure Function is deployed and running
2. The API URL in `.env.local` matches your deployment
3. CORS is configured on the Azure Function to allow requests from your domain

## Project Structure

```
src/
├── app/
│   ├── api/auth/[...nextauth]/     # NextAuth API routes
│   ├── auth/signin/                # Custom sign-in page
│   ├── layout.tsx                  # Root layout
│   └── page.tsx                    # Home page
├── components/
│   ├── ui/                         # shadcn/ui components
│   ├── FactChecker.tsx             # Main fact-checking component
│   ├── Header.tsx                  # Navigation header
│   └── Providers.tsx               # Session provider wrapper
├── lib/
│   ├── api.ts                      # API service functions
│   ├── auth.ts                     # NextAuth configuration
│   ├── types.ts                    # TypeScript type definitions
│   └── utils.ts                    # Utility functions
└── types/
    └── next-auth.d.ts              # NextAuth type extensions
```

## Usage

1. **Sign In**: Click "Sign in" and choose Google or Facebook
2. **Enter Text**: Type or paste the text you want to fact-check
3. **Submit**: Click "Fact-Check" to process your request
4. **View Results**: See real-time streaming results and source citations
5. **Verify Sources**: Click on source links to verify information

## Features in Detail

### Real-time Streaming
The application supports real-time streaming of results, showing the AI's analysis as it processes your text.

### Source Citations
Each fact-check result includes clickable source links that open in new tabs, allowing you to verify the information independently.

### Authentication
Secure authentication with popular OAuth providers ensures user privacy and enables personalized features.

### Responsive Design
The interface adapts to different screen sizes, providing an optimal experience on both desktop and mobile devices.

## Troubleshooting

### Common Issues

1. **Authentication not working**: Check OAuth credentials and redirect URIs
2. **API connection failed**: Verify the Azure Function URL and CORS settings
3. **Build errors**: Ensure all dependencies are installed and environment variables are set

### Environment Variables
Make sure all required environment variables are set in `.env.local`:
- `NEXTAUTH_URL`: Your application URL
- `NEXTAUTH_SECRET`: A secure random string
- OAuth client IDs and secrets

## Development

### Adding New Features
1. Create components in `src/components/`
2. Add API functions in `src/lib/api.ts`
3. Update types in `src/lib/types.ts`
4. Follow the existing code style and patterns

### Testing
```bash
npm run lint        # Run ESLint
npm run type-check  # Run TypeScript checks
```

## Deployment

### Vercel (Recommended)
1. Connect your GitHub repository to Vercel
2. Set environment variables in Vercel dashboard
3. Deploy automatically on git push

### Other Platforms
The application can be deployed to any platform that supports Next.js applications.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
