from fastapi import APIRouter
from models.user import UserRegistration
from services.user_service import user_service

router = APIRouter(prefix="", tags=["users"])


@router.post("/register")
async def register_user(user: UserRegistration):
    return user_service.register_user(user.username, user.public_key)


@router.get("/users/{username}/public-key")
async def get_public_key(username: str):
    return user_service.get_public_key(username)


@router.get("/users")
async def list_users():
    return user_service.get_all_users()
