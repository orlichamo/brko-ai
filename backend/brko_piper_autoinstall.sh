#!/bin/bash
set -e

echo "🧠 Brko → Piper TTS migracija (low-RAM optimizacija)"

# ---------------------------
# 1. OS paketi
# ---------------------------
sudo apt update
sudo apt install -y \
  curl \
  git \
  ffmpeg \
  python3 \
  python3-venv \
  unzip

# ---------------------------
# 2. Python venv
# ---------------------------
cd ~/brko/backend || exit 1

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install fastapi uvicorn requests soundfile numpy

# ---------------------------
# 3. Piper TTS (bin)
# ---------------------------
mkdir -p piper
cd piper

if [ ! -f piper ]; then
  echo "📥 Preuzimam Piper..."
  curl -L -o piper.tar.gz \
    https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz
  tar -xzf piper.tar.gz
  chmod +x piper
fi

# ---------------------------
# 4. Glas – Srećko (BCS-friendly)
# ---------------------------
mkdir -p voices
cd voices

VOICE=sr_RS-ivona-medium.onnx

if [ ! -f "$VOICE" ]; then
  echo "🎙️ Preuzimam glas Srećko (sr/hr kompatibilan)..."
  curl -L -O \
    https://huggingface.co/rhasspy/piper-voices/resolve/main/sr/sr_RS/ivona/medium/sr_RS-ivona-medium.onnx
  curl -L -O \
    https://huggingface.co/rhasspy/piper-voices/resolve/main/sr/sr_RS/ivona/medium/sr_RS-ivona-medium.onnx.json
fi

cd ../../

# ---------------------------
# 5. TTS modul (tts.py)
# ---------------------------
cat > tts.py << 'EOF'
import subprocess
import uuid
import os

BASE_DIR = os.path.dirname(__file__)
PIPER = os.path.join(BASE_DIR, "piper", "piper")
VOICE = os.path.join(
    BASE_DIR,
    "piper",
    "voices",
    "sr_RS-ivona-medium.onnx"
)

def tts_to_wav(text: str) -> str:
    out = f"/tmp/brko_{uuid.uuid4().hex}.wav"

    subprocess.run(
        [
            PIPER,
            "--model", VOICE,
            "--output_file", out
        ],
        input=text.encode("utf-8"),
        check=True
    )

    return out
EOF

# ---------------------------
# 6. Chat engine (phi3:mini)
# ---------------------------
cat > chat_engine.py << 'EOF'
import requests

OLLAMA_URL = "http://localhost:11434/api/generate"

SYSTEM_PROMPT = """
Ti si Brko.
Govoriš prirodno, jasno i prijateljski.
Pričaš kao Srećko – topao, smiren, ljudski glas.
Uvijek odgovaraš na hrvatskom ili srpskom.
Bez emojija u govoru.
Kratke, jasne rečenice.
"""

def ask_brko(text: str) -> str:
    payload = {
        "model": "phi3:mini",
        "prompt": f"{SYSTEM_PROMPT}\nKorisnik: {text}\nBrko:",
        "stream": False
    }

    r = requests.post(OLLAMA_URL, json=payload, timeout=120)
    r.raise_for_status()
    return r.json()["response"]
EOF

# ---------------------------
# 7. FastAPI main.py
# ---------------------------
cat > main.py << 'EOF'
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.responses import FileResponse

from chat_engine import ask_brko
from tts import tts_to_wav

app = FastAPI()

class ChatRequest(BaseModel):
    text: str

@app.post("/chat")
def chat(req: ChatRequest):
    answer = ask_brko(req.text)
    wav = tts_to_wav(answer)

    return FileResponse(
        wav,
        media_type="audio/wav",
        filename="brko.wav"
    )
EOF

echo "✅ Brko je uspješno prebačen na Piper TTS"
echo "▶️ Pokreni backend sa:"
echo "source venv/bin/activate && uvicorn main:app --host 0.0.0.0 --port 8001"
