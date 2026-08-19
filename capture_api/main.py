from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, captures, spaces

app = FastAPI(
    title="Capture API",
    description="Backend for Capture app with semantic search and context spaces",
    version="0.1.0"
)

# Setup CORS to allow Flutter app to communicate with FastAPI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For beta, allow all. Restrict to specific domains in prod.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(captures.router)
app.include_router(spaces.router)

@app.get("/")
async def root():
    return {"message": "Welcome to Capture API. Access /docs for API documentation."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
