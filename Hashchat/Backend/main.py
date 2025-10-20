from fastapi import FastAPI, WebSocket
import uvicorn

app = FastAPI()
connections = []

@app.websocket("/ws")
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
        connections.remove(websocket)

if __name__ == "__main__":
    uvicorn.run("main:app", host="localhost", port=12345, reload=True)
