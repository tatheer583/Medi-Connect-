import google.generativeai as genai
from app.core.config import GOOGLE_API_KEY

class AIAgent:
    def __init__(self):
        if GOOGLE_API_KEY:
            genai.configure(api_key=GOOGLE_API_KEY)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    async def generate_pre_appointment_summary(self, patient_data: dict, history: list):
        """
        Generates a clinical summary for the doctor before an appointment using Gemini.
        """
        if not self.model:
            return "AI Agent not configured. Please provide Google API Key."

        prompt = f"""
        You are a medical AI assistant. Generate a concise pre-appointment summary for a doctor.
        Patient: {patient_data['name']}, {patient_data['age']} years old.
        Conditions: {patient_data.get('chronic_conditions', 'None')}
        Allergies: {patient_data.get('allergies', 'None')}
        
        Recent History:
        {history}
        
        Focus on:
        1. Key changes since last visit.
        2. Potential risks or missed medications.
        3. Specific questions the doctor should ask.
        Keep it professional and under 150 words.
        """

        response = await self.model.generate_content_async(prompt)
        return response.text

    async def analyze_symptoms(self, symptoms: str):
        """
        Provides initial symptom analysis (not a diagnosis).
        """
        # Placeholder for Phase 3
        pass

ai_agent = AIAgent()
