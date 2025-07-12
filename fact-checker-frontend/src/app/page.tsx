import FactChecker from "@/components/FactChecker";

export default function Home() {
  return (
    <div className="container mx-auto py-8">
      <div className="text-center mb-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          AI Fact Checker ✨
        </h1>
        <p className="text-xl text-gray-600 max-w-2xl mx-auto">
          Verify information instantly with our AI-powered fact-checking tool. 
          Enter any statement and get reliable, source-backed verification.
          🚀 Now deployed with GitHub Actions!
        </p>
      </div>
      
      <FactChecker />
    </div>
  );
}
