from typing import Union

from fastapi import FastAPI, WebSocket
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from llama_index.llms import LlamaCPP
from llama_index.llms.llama_utils import messages_to_prompt, completion_to_prompt
from pydantic import BaseModel
import psutil
import uvicorn

class SystemStats(BaseModel):
    ram_total: str
    ram_used:str
    ram_available: str
    cpu_percentage: str
    disk_available:str
    disk_percentage : str
    disk_used : str

class Prompt(BaseModel):
    request:str

app = FastAPI()

origins = [
    '*'
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

llm = LlamaCPP(
    
    model_url="https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q2_K.gguf",
    # optionally, you can set the path to a pre-downloaded model instead of model_url
    #model_path='./models/llama-2-7b-chat.ggmlv3.q2_K.bin',
    temperature=0.1,
    max_new_tokens=256,
    # llama2 has a context window of 4096 tokens, but we set it lower to allow for some wiggle room
    context_window=3900,
    # kwargs to pass to __call__()
    generate_kwargs={},
    # kwargs to pass to __init__()
    # set to at least 1 to use GPU
    #model_kwargs={"n_gpu_layers": 1},
    # transform inputs into Llama2 format
    messages_to_prompt=messages_to_prompt,
    completion_to_prompt=completion_to_prompt,
    verbose=False,
)

async def llmResponse(prompt):
    response_iter = llm.stream_complete(prompt)
    for response in response_iter:
        print(response.delta, end="", flush=True)
        yield response.delta


@app.websocket("/chat")
async def read_stream_websocket(websocket: WebSocket):
    await websocket.accept()
    while True:
        prompt = await websocket.receive_text()
        response_iter = llm.stream_complete(prompt)
        for response in response_iter:
            print(response.delta, end="", flush=True)
            await websocket.send_text(repr(response.delta))




@app.get("/prompt/stream/{prompt}")
def read_stream_async(prompt):
    return StreamingResponse(llmResponse(prompt),media_type='text/event-stream')  # type: ignore


@app.post("/prompt/")
def read_sync(prompt:Prompt):
    return llm.complete(prompt.request).text; 

@app.get("/systemstats")
def get_system_stats():
    try:
        ram_info = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent()
    
        disk_info = psutil.disk_usage("/")
        return SystemStats(ram_available=f"{ram_info.free / 1024 / 1024 / 1024:.2f} GB",
                           ram_total=f"{ram_info.total / 1024 / 1024 / 1024:.2f} GB",
                           ram_used=f"{ram_info.used / 1024 / 1024 / 1024:.2f} GB",
                           cpu_percentage=f"{cpu_percent}",
                           disk_available=f"{disk_info.free / 1024 / 1024 / 1024:.2f} GB",
                           disk_percentage=f"{disk_info.percent / 1024 / 1024 / 1024:.2f} GB",
                           disk_used=f"{disk_info.used / 1024 / 1024 / 1024:.2f} GB")
        
    except FileNotFoundError:
        print("Either Ram, CPU or disk info not available on this system")


if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=4557, reload=True)