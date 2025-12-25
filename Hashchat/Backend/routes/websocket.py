from fastapi import APIRouter, WebSocket
from typing import List

router = APIRouter(tags=["websocket"])

connections: List[WebSocket] = []


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections.append(websocket)

    try:
        while True:
            data = await websocket.receive_text()

            for conn in connections:
                if conn != websocket:
                    await conn.send_text(data)
    except:
        pass
    finally:
        if websocket in connections:
            connections.remove(websocket)


def get_active_connections_count() -> int:
    return len(connections)
