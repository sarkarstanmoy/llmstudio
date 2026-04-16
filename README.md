# LLM Studio

A cross-platform local LLM inference platform. Run Code Llama 7B entirely on your machine and interact with it through a native mobile, web, or desktop app — no cloud required.

---

## Architecture

```
llmstudio/
└── Monorepo/llama-studio/
    ├── apps/
    │   ├── server/          # Python · FastAPI · llama-cpp-python
    │   └── neullmstudio/    # Flutter · GetX · Dio
    └── packages/
        ├── ui/              # Shared React component library
        ├── tsconfig/        # Shared TypeScript configs
        └── eslint-config-custom/
```

| Layer | Stack |
|-------|-------|
| Backend | Python 3.11, FastAPI, llama-cpp-python, LlamaIndex, Uvicorn |
| Frontend | Flutter 3, Dart, GetX, Dio, WebSocket |
| Build | Turborepo, npm workspaces |
| Container | Docker, Docker Compose, Nginx |

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Python | 3.11+ | [python.org](https://www.python.org/downloads/) |
| Flutter | 3.0.6+ | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org/) |
| npm | 9.6.7+ | bundled with Node.js |
| Docker | any | [docker.com](https://www.docker.com/get-started/) *(optional — for containerised run)* |

> **Note:** `llama-cpp-python` compiles native extensions. On macOS you need Xcode Command Line Tools (`xcode-select --install`). On Linux, `gcc` and `cmake` must be available.

---

## Quick Start

### 1 — Clone & install JS dependencies

```bash
git clone https://github.com/sarkarstanmoy/llmstudio.git
cd llmstudio/Monorepo/llama-studio
npm install
```

---

### 2 — Run the Backend (FastAPI + Code Llama 7B)

```bash
cd apps/server

# Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate

# Install Python dependencies
pip install -r requirements.txt

# Start the server  (downloads the model on first run — ~3.9 GB)
uvicorn main:app --host 127.0.0.1 --port 4557 --reload

# To allow access from other devices on the LAN (e.g. a physical phone):
# uvicorn main:app --host 0.0.0.0 --port 4557 --reload
```

The server will be available at `http://localhost:4557`.

#### API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/systemstats` | RAM, CPU, and disk usage |
| `GET` | `/prompt/stream/{prompt}` | Streaming SSE completion |
| `POST` | `/prompt/` | Synchronous completion — body: `{ "request": "..." }` |
| `WS` | `/chat` | WebSocket chat — send text, receive streamed tokens |

Interactive docs: `http://localhost:4557/docs`

---

### 3 — Run the Flutter Client

```bash
cd apps/neullmstudio

# Fetch Dart/Flutter dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on macOS desktop
flutter run -d macos

# Run on a connected Android/iOS device
flutter run
```

> The app connects to `http://localhost:4557` by default. Change the base URL in **Settings** if your server is on a different host/port.

---

### Alternative: Docker Compose (server only)

```bash
cd apps/server

# Build the image
docker build -t llama-7b-api .

# Start with Nginx reverse proxy (port 80 → 3100)
docker-compose up
```

---

## Development — Full Monorepo

From the repo root run all apps in parallel with Turborepo:

```bash
cd Monorepo/llama-studio
npm run dev      # starts all apps
npm run build    # builds all packages
npm run lint     # lints TypeScript packages
npm run format   # formats .ts/.tsx/.md files
```

> The Python server is invoked by Turborepo via the `dev` script in `apps/server/package.json` — make sure your virtual environment is active or the `uvicorn` binary is on your PATH before running `npm run dev`.

---

## Project Details

### Backend (`apps/server`)

- Loads **CodeLlama-7B-Instruct** (GGUF Q2_K, ~3.9 GB) from Hugging Face on first start. The file is cached locally by `llama-cpp-python`.
- Streams tokens via Server-Sent Events (`StreamingResponse`) and WebSocket.
- Reports live system stats (RAM, CPU, disk) via `/systemstats`.
- CORS is open to all origins for local development — tighten `origins` in `main.py` before deploying to production.

### Flutter Client (`apps/neullmstudio`)

- **State management:** GetX
- **HTTP client:** Dio
- **Real-time chat:** `web_socket_channel`
- **Screens:** Home, Chat, Settings, System Stats, Local Server, Instructions, Offline fallback
- Supports iOS, Android, Web, macOS, Linux, Windows from a single codebase.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `llama-cpp-python` install fails | Ensure C/C++ build tools are installed. On macOS: `xcode-select --install`. |
| Model download is slow / fails | Set `model_path` in `main.py` to a pre-downloaded GGUF file and comment out `model_url`. |
| `uvicorn` not found | Activate the virtual environment: `source apps/server/.venv/bin/activate`. |
| Flutter can't reach server | Check server is running on port 4557 and update the base URL in the app's Settings screen. |
| `flutter run -d chrome` fails | Run `flutter doctor` and follow the reported fixes. |

---

## Deployment

The server is ready to push to **Azure Container Registry**:

```bash
az acr login --name neullmstudio
docker tag llama-7b-api neullmstudio.azurecr.io/llm/llama-7b-ggml-api
docker push neullmstudio.azurecr.io/llm/llama-7b-ggml-api
```

---

## License

UNLICENSED — private project.
