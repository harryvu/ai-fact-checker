import azure.functions as func
import json
import logging
import os
import re
from typing import Dict, List, Optional, Any

import requests
from pydantic import BaseModel, Field
from newspaper import Article, ArticleException
from requests.exceptions import RequestException


class Claim(BaseModel):
    """Model for representing a single claim and its fact check."""
    claim: str = Field(description="The specific claim extracted from the text")
    rating: str = Field(description="Rating of the claim: TRUE, FALSE, MISLEADING, or UNVERIFIABLE")
    explanation: str = Field(description="Detailed explanation with supporting evidence")
    sources: List[str] = Field(description="List of sources used to verify the claim")


class FactCheckResult(BaseModel):
    """Model for the complete fact check result."""
    overall_rating: str = Field(description="Overall rating: MOSTLY_TRUE, MIXED, or MOSTLY_FALSE")
    summary: str = Field(description="Brief summary of the overall findings")
    claims: List[Claim] = Field(description="List of specific claims and their fact checks")


class FactChecker:
    """A class to interact with Perplexity Sonar API for fact checking."""

    API_URL = "https://api.perplexity.ai/chat/completions"
    DEFAULT_MODEL = "sonar-pro"
    
    # Models that support structured outputs (ensure your tier has access)
    STRUCTURED_OUTPUT_MODELS = ["sonar", "sonar-pro", "sonar-reasoning", "sonar-reasoning-pro"]

    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize the FactChecker with API key and system prompt.

        Args:
            api_key: Perplexity API key. If None, will try to read from environment.
        """
        self.api_key = api_key or self._get_api_key()
        if not self.api_key:
            raise ValueError(
                "API key not found. Please provide via environment variable PPLX_API_KEY."
            )
        
        self.system_prompt = self._get_default_system_prompt()

    def _get_api_key(self) -> str:
        """
        Try to get API key from environment.

        Returns:
            The API key if found, empty string otherwise.
        """
        return os.environ.get("PPLX_API_KEY", "")

    def _get_default_system_prompt(self) -> str:
        """
        Get the default system prompt.

        Returns:
            The system prompt as a string
        """
        return """You are a professional fact-checker with extensive research capabilities. Your task is to evaluate claims or articles for factual accuracy. Focus on identifying false, misleading, or unsubstantiated claims.

## Evaluation Process
For each piece of content, you will:
1. Identify specific claims that can be verified
2. Research each claim thoroughly using the most reliable sources available
3. Determine if each claim is:
   - TRUE: Factually accurate and supported by credible evidence
   - FALSE: Contradicted by credible evidence
   - MISLEADING: Contains some truth but presents information in a way that could lead to incorrect conclusions
   - UNVERIFIABLE: Cannot be conclusively verified with available information
4. For claims rated as FALSE or MISLEADING, explain why and provide corrections

## Rating Criteria
- TRUE: Claim is supported by multiple credible sources with no significant contradicting evidence
- FALSE: Claim is contradicted by clear evidence from credible sources
- MISLEADING: Claim contains factual elements but is presented in a way that omits crucial context or leads to incorrect conclusions
- UNVERIFIABLE: Claim cannot be conclusively verified or refuted with available evidence

## Guidelines
- Remain politically neutral and focus solely on factual accuracy
- Do not use political leaning as a factor in your evaluation
- Prioritize official data, peer-reviewed research, and reports from credible institutions
- Cite specific, reliable sources for your determinations
- Consider the context and intended meaning of statements
- Distinguish between factual claims and opinions
- Pay attention to dates, numbers, and specific details
- Be precise and thorough in your explanations

## Response Format
Respond in JSON format with the following structure:
```json
{
    "overall_rating": "MOSTLY_TRUE|MIXED|MOSTLY_FALSE",
    "summary": "Brief summary of your overall findings",
    "claims": [
        {
            "claim": "The specific claim extracted from the text",
            "rating": "TRUE|FALSE|MISLEADING|UNVERIFIABLE",
            "explanation": "Your explanation with supporting evidence",
            "sources": ["Source 1", "Source 2"]
        }
    ]
}
```

## Criteria for Overall Rating
- MOSTLY_TRUE: Most claims are true, with minor inaccuracies that don't affect the main message
- MIXED: The content contains a roughly equal mix of true and false/misleading claims
- MOSTLY_FALSE: Most claims are false or misleading"""

    def check_claim(self, text: str, model: str = DEFAULT_MODEL, use_structured_output: bool = False) -> Dict[str, Any]:
        """
        Check the factual accuracy of a claim or article.

        Args:
            text: The claim or article text to fact check
            model: The Perplexity model to use
            use_structured_output: Whether to use structured output API (if model supports it)

        Returns:
            The parsed response containing fact check results.
        """
        if not text or not text.strip():
            return {"error": "Input text is empty. Cannot perform fact check."}
        
        user_prompt = f"Fact check the following text and identify any false or misleading claims:\n\n{text}"

        headers = {
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }

        data = {
            "model": model,
            "messages": [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": user_prompt}
            ]
        }

        can_use_structured_output = model in self.STRUCTURED_OUTPUT_MODELS and use_structured_output
        if can_use_structured_output:
            data["response_format"] = {
                "type": "json_schema",
                "json_schema": {"schema": FactCheckResult.model_json_schema()},
            }

        try:
            response = requests.post(self.API_URL, headers=headers, json=data)
            response.raise_for_status()
            result = response.json()
            
            citations = result.get("citations", [])
            
            if "choices" in result and result["choices"] and "message" in result["choices"][0]:
                content = result["choices"][0]["message"]["content"]
                
                if can_use_structured_output:
                    try:
                        parsed = json.loads(content)
                        if citations and "citations" not in parsed:
                            parsed["citations"] = citations
                        # Resolve citation references in the structured output
                        if citations and "claims" in parsed:
                            self._resolve_citations_in_claims(parsed["claims"], citations)
                        return parsed
                    except json.JSONDecodeError as e:
                        return {"error": f"Failed to parse structured output: {str(e)}", "raw_response": content, "citations": citations}
                else:
                    parsed = self._parse_response(content)
                    if citations and "citations" not in parsed:
                        parsed["citations"] = citations
                    # Resolve citation references in the parsed output
                    if citations and "claims" in parsed:
                        self._resolve_citations_in_claims(parsed["claims"], citations)
                    return parsed
            
            return {"error": "Unexpected API response format", "raw_response": result}
            
        except requests.exceptions.RequestException as e:
            return {"error": f"API request failed: {str(e)}"}
        except json.JSONDecodeError:
            return {"error": "Failed to parse API response as JSON"}
        except Exception as e:
            return {"error": f"Unexpected error: {str(e)}"}

    def _resolve_citations_in_claims(self, claims: List[Dict[str, Any]], citations: List[str]) -> None:
        """
        Resolve citation references like [1], [2] to actual URLs in the claims.
        
        Args:
            claims: List of claim dictionaries to update
            citations: List of actual citation URLs
        """
        for claim in claims:
            if "sources" in claim and claim["sources"]:
                updated_sources = []
                for source in claim["sources"]:
                    m = re.match(r"\[(\d+)\]", source.strip())
                    if m:
                        idx = int(m.group(1)) - 1
                        if 0 <= idx < len(citations):
                            updated_sources.append(citations[idx])
                        else:
                            updated_sources.append(source)
                    else:
                        updated_sources.append(source)
                claim["sources"] = updated_sources

    def _parse_response(self, content: str) -> Dict[str, Any]:
        """
        Parse the response content to extract JSON if possible.
        If not, fall back to extracting citations from the text.

        Args:
            content: The response content from the API

        Returns:
            A dictionary with parsed JSON fields or with a fallback containing raw response and extracted citations.
        """
        try:
            if "```json" in content:
                json_content = content.split("```json")[1].split("```")[0].strip()
                return json.loads(json_content)
            elif "```" in content:
                json_content = content.split("```")[1].split("```")[0].strip()
                return json.loads(json_content)
            else:
                return json.loads(content)
        except (json.JSONDecodeError, IndexError):
            citations = re.findall(r"Sources?:\s*(.+)", content)
            return {
                "raw_response": content,
                "extracted_citations": citations if citations else "No citations found"
            }


def main(req: func.HttpRequest) -> func.HttpResponse:
    """Main Azure Function entry point."""
    logging.info('Python HTTP trigger function processed a request.')

    try:
        # Get request method
        method = req.method.upper()
        
        if method == "GET":
            return func.HttpResponse(
                json.dumps({
                    "message": "Fact Checker API",
                    "description": "Send a POST request with text, file content, or URL to fact-check",
                    "usage": {
                        "text": "Send JSON with 'text' field",
                        "url": "Send JSON with 'url' field",
                        "parameters": {
                            "model": "Perplexity model to use (default: sonar-pro)",
                            "structured_output": "Boolean to enable structured output (default: false)"
                        }
                    }
                }),
                status_code=200,
                headers={"Content-Type": "application/json"}
            )
        
        elif method == "POST":
            try:
                # Parse request body
                req_body = req.get_json()
                if not req_body:
                    return func.HttpResponse(
                        json.dumps({"error": "Request body must be valid JSON"}),
                        status_code=400,
                        headers={"Content-Type": "application/json"}
                    )
                
                # Extract parameters
                text = req_body.get('text')
                url = req_body.get('url')
                model = req_body.get('model', 'sonar-pro')
                structured_output = req_body.get('structured_output', False)
                
                if not text and not url:
                    return func.HttpResponse(
                        json.dumps({"error": "Either 'text' or 'url' parameter is required"}),
                        status_code=400,
                        headers={"Content-Type": "application/json"}
                    )
                
                # Initialize fact checker
                fact_checker = FactChecker()
                
                # Get text content
                if url:
                    try:
                        logging.info(f"Fetching content from URL: {url}")
                        response = requests.get(url, timeout=15)
                        response.raise_for_status()
                        
                        article = Article(url=url)
                        article.download(input_html=response.text)
                        article.parse()
                        text = article.text
                        
                        if not text:
                            return func.HttpResponse(
                                json.dumps({"error": f"Could not extract text from URL: {url}"}),
                                status_code=400,
                                headers={"Content-Type": "application/json"}
                            )
                    except RequestException as e:
                        return func.HttpResponse(
                            json.dumps({"error": f"Error fetching URL: {str(e)}"}),
                            status_code=400,
                            headers={"Content-Type": "application/json"}
                        )
                    except ArticleException as e:
                        return func.HttpResponse(
                            json.dumps({"error": f"Error parsing article content: {str(e)}"}),
                            status_code=400,
                            headers={"Content-Type": "application/json"}
                        )
                    except Exception as e:
                        return func.HttpResponse(
                            json.dumps({"error": f"Unexpected error processing URL: {str(e)}"}),
                            status_code=500,
                            headers={"Content-Type": "application/json"}
                        )
                
                if not text or not text.strip():
                    return func.HttpResponse(
                        json.dumps({"error": "No text found to fact check"}),
                        status_code=400,
                        headers={"Content-Type": "application/json"}
                    )
                
                # Perform fact check
                logging.info("Starting fact check process")
                results = fact_checker.check_claim(
                    text=text,
                    model=model,
                    use_structured_output=structured_output
                )
                
                # Return results
                return func.HttpResponse(
                    json.dumps(results, indent=2),
                    status_code=200,
                    headers={"Content-Type": "application/json"}
                )
                
            except json.JSONDecodeError:
                return func.HttpResponse(
                    json.dumps({"error": "Invalid JSON in request body"}),
                    status_code=400,
                    headers={"Content-Type": "application/json"}
                )
            except ValueError as e:
                return func.HttpResponse(
                    json.dumps({"error": str(e)}),
                    status_code=400,
                    headers={"Content-Type": "application/json"}
                )
            except Exception as e:
                logging.error(f"Unexpected error: {str(e)}")
                return func.HttpResponse(
                    json.dumps({"error": f"Internal server error: {str(e)}"}),
                    status_code=500,
                    headers={"Content-Type": "application/json"}
                )
        
        else:
            return func.HttpResponse(
                json.dumps({"error": f"Method {method} not allowed"}),
                status_code=405,
                headers={"Content-Type": "application/json"}
            )
    
    except Exception as e:
        logging.error(f"Critical error: {str(e)}")
        return func.HttpResponse(
            json.dumps({"error": "Internal server error"}),
            status_code=500,
            headers={"Content-Type": "application/json"}
        )
