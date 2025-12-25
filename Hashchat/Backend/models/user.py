from pydantic import BaseModel


class UserRegistration(BaseModel):
    username: str
    public_key: str
