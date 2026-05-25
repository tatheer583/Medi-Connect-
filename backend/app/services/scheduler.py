from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.services.ai_agent import ai_agent
from app.core.config import supabase

scheduler = AsyncIOScheduler()

async def check_upcoming_appointments():
    """
    Checks for appointments starting in 30 minutes and triggers AI summary.
    """
    # This is a conceptual implementation. 
    # Real implementation would query Supabase for appointments.
    print("Checking upcoming appointments...")
    pass

async def send_medicine_reminders():
    """
    Checks for scheduled medicine doses and sends push notifications.
    """
    print("Checking medicine reminders...")
    pass

def start_scheduler():
    scheduler.add_job(check_upcoming_appointments, 'interval', minutes=15)
    scheduler.add_job(send_medicine_reminders, 'cron', minute='0,15,30,45')
    scheduler.start()
