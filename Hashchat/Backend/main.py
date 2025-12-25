from fastapi import FastAPI
from routes import users, websocket
from routes.websocket import get_active_connections_count
from services.user_service import user_service
import uvicorn

app = FastAPI(
    title="Hashchat",
    description=(
        "Real-time encrypted messaging server with WebSocket relay and RSA E2EE support.\n\n"
        "Supported ciphers: RSA (E2EE), AES, DES, Caesar, Vigenere, Columnar, Polybius, Pigpen, Hill, Rail Fence, Euclid, Rota."
    ),
    version="2.0.0",
)


@app.get("/health", tags=["system"])
async def health_check():
    stats = user_service.get_stats()
    return {
        "status": "healthy",
        "registered_users": stats["registered_users"],
        "active_connections": get_active_connections_count(),
    }


app.include_router(users.router)
app.include_router(websocket.router)


if __name__ == "__main__":
    print("Hashchat E2EE Server Starting...")
    print("REST API: http://localhost:12345")
    print("WebSocket: ws://localhost:12345/ws")
    print("API Docs: http://localhost:12345/docs")

    uvicorn.run("main:app", host="localhost", port=12345, reload=True)
