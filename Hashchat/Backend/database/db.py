from typing import Dict, Optional


class Database:

    def __init__(self):
        self._users: Dict[str, str] = {}

    def add_user(self, username: str, public_key: str) -> None:
        self._users[username] = public_key

    def get_public_key(self, username: str) -> Optional[str]:
        return self._users.get(username)

    def user_exists(self, username: str) -> bool:
        return username in self._users

    def get_all_usernames(self) -> list[str]:
        return list(self._users.keys())

    def count_users(self) -> int:
        return len(self._users)


db = Database()
