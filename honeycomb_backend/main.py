import os
import json
import re
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import anthropic

load_dotenv()

app = FastAPI(title="Honeycomb AI Engine")

# Allow Flutter Web frontend to communicate with FastAPI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

api_key = os.getenv("ANTHROPIC_API_KEY")

class SearchQuery(BaseModel):
    query: str
    user_id: str

@app.post("/api/search")
async def honeycomb_search(payload: SearchQuery):
    if not api_key:
        return {
            "answer": "Error: ANTHROPIC_API_KEY is not set in honeycomb_backend/.env file.",
            "sources": [{"title": "Setup Guide", "url": "https://docs.anthropic.com"}],
            "suggestions": ["Check .env file", "Restart Uvicorn", "Verify API Key"]
        }

    try:
        client = anthropic.Anthropic(api_key=api_key)
        system_prompt = """
        You are Honeycomb, an advanced AI news engine.
        You MUST respond ONLY with a raw, valid JSON object.
        DO NOT include markdown block formatting (e.g., do not use ```json or ```).
        
        Required JSON structure:
        {
          "answer": "Concise, factual synthesis of the topic.",
          "sources": [
            {"title": "Source Title", "url": "https://example.com"}
          ],
          "suggestions": ["Follow-up Question 1", "Follow-up Question 2", "Follow-up Question 3"]
        }
        """

        # Using an active model ID provisioned for your account
        response = client.messages.create(
            model="claude-sonnet-5",
            max_tokens=1000,
            system=system_prompt,
            messages=[{"role": "user", "content": f"Explain and analyze: {payload.query}"}]
        )

        content = response.content[0].text.strip()
        
        # Clean markdown wrappers if returned
        content = re.sub(r"^```(?:json)?\s*", "", content, flags=re.IGNORECASE)
        content = re.sub(r"\s*```$", "", content)
        
        data = json.loads(content)
        return data

    except anthropic.AuthenticationError:
        return {
            "answer": "API Error: Invalid Anthropic API Key. Please check your .env key.",
            "sources": [{"title": "Anthropic Console", "url": "https://console.anthropic.com"}],
            "suggestions": ["Check API Key", "Update .env"]
        }
    except anthropic.NotFoundError as e:
        return {
            "answer": f"Anthropic Model Error: {str(e)}",
            "sources": [],
            "suggestions": ["Check Model Name", "Update Python Backend"]
        }
    except anthropic.BadRequestError as e:
        return {
            "answer": f"Anthropic Bad Request: {str(e)}",
            "sources": [],
            "suggestions": ["Try another query"]
        }
    except Exception as e:
        print(f"Backend Exception: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def root():
    return {"status": "Honeycomb AI Engine Live"}