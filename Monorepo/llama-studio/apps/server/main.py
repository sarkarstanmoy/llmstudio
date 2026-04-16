from fastapi import FastAPI, WebSocket, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from llama_cpp import Llama
from pydantic import BaseModel
from typing import Optional
import psutil
import uvicorn

MODEL_REPO = "TheBloke/CodeLlama-7B-Instruct-GGUF"
MODEL_FILE = "codellama-7b-instruct.Q2_K.gguf"

# Loaded lazily on first inference request so the server starts immediately.
_llm: Optional[Llama] = None


def get_llm() -> Llama:
    global _llm
    if _llm is None:
        print(f"Loading model {MODEL_FILE} (first request — may download ~3.9 GB)…")
        _llm = Llama.from_pretrained(
            repo_id=MODEL_REPO,
            filename=MODEL_FILE,
            verbose=False,
            n_ctx=3900,
        )
        print("Model loaded.")
    return _llm


class SystemStats(BaseModel):
    ram_total: str
    ram_used: str
    ram_available: str
    cpu_percentage: str
    disk_total: str
    disk_used: str
    disk_available: str
    disk_percentage: str


class Prompt(BaseModel):
    request: str


app = FastAPI(title="LLM Studio API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": _llm is not None}


async def llm_stream(prompt: str):
    llm = get_llm()
    for chunk in llm(prompt, max_tokens=256, stream=True):
        token = chunk["choices"][0]["text"]
        if token:
            print(token, end="", flush=True)
            yield token


@app.websocket("/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()
    llm = get_llm()
    while True:
        prompt = await websocket.receive_text()
        for chunk in llm(prompt, max_tokens=256, stream=True):
            token = chunk["choices"][0]["text"]
            if token:
                await websocket.send_text(token)


@app.get("/prompt/stream/{prompt}")
def stream_prompt(prompt: str):
    return StreamingResponse(llm_stream(prompt), media_type="text/event-stream")


@app.post("/prompt/")
def sync_prompt(prompt: Prompt):
    result = get_llm()(prompt.request, max_tokens=256)
    return result["choices"][0]["text"]


@app.get("/systemstats", response_model=SystemStats)
def get_system_stats():
    ram = psutil.virtual_memory()
    disk = psutil.disk_usage("/")
    return SystemStats(
        ram_total=f"{ram.total / 1024**3:.2f} GB",
        ram_used=f"{ram.used / 1024**3:.2f} GB",
        ram_available=f"{ram.free / 1024**3:.2f} GB",
        cpu_percentage=str(psutil.cpu_percent()),
        disk_total=f"{disk.total / 1024**3:.2f} GB",
        disk_used=f"{disk.used / 1024**3:.2f} GB",
        disk_available=f"{disk.free / 1024**3:.2f} GB",
        disk_percentage=f"{disk.percent:.1f}%",
    )


if __name__ == "__main__":
    # Use --host 0.0.0.0 on the CLI if you need access from other devices on the LAN.
    uvicorn.run("main:app", host="127.0.0.1", port=4557, reload=True)
