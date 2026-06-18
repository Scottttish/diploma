from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routers import auth, tasks, users, telegram, notifications, analytics, directories, clients, conversations

import app.models.conversation  
import app.models.message      

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    description="Central backend hub for the Service Company Information System",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

api_router = APIRouter(prefix="/api")

api_router.include_router(auth.router)
api_router.include_router(tasks.router)
api_router.include_router(users.router)
api_router.include_router(telegram.router)
api_router.include_router(notifications.router)
api_router.include_router(analytics.router)
api_router.include_router(directories.router)
api_router.include_router(clients.router)
api_router.include_router(conversations.router)

app.include_router(api_router)

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok", "app": settings.APP_NAME}
