from fastapi import FastAPI, BackgroundTasks
from app.services.scheduler import start_scheduler
from app.services.ai_agent import ai_agent
from pydantic import BaseModel

app = FastAPI(title="MediConnect API")

@app.on_event("startup")
async def startup_event():
    start_scheduler()

class SummaryRequest(BaseModel):
    patient_data: dict
    history: list

@app.post("/ai/summary")
async def get_summary(request: SummaryRequest):
    summary = await ai_agent.generate_pre_appointment_summary(
        request.patient_data, 
        request.history
    )
    return {"summary": summary}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/")
async def root():
    return {"message": "Welcome to MediConnect API"}
