from typing import Union

from fastapi import FastAPI, WebSocket
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from llama_index.llms import LlamaCPP
from llama_index.llms.llama_utils import messages_to_prompt, completion_to_prompt
from pydantic import BaseModel

class Prompt(BaseModel):
    request: str

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

@app.post("/chat/stop")
def stop():
    return llm.complete("stop")
