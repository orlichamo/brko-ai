#!/bin/bash
set -e

echo "🧠 Brko – kompletna auto instalacija pokrenuta"

# -----------------------------
# OS & BASIC TOOLS
# -----------------------------
sudo apt update
sudo apt install -y curl git ffmpeg python3 python3-venv python3-pip

# -----------------------------
# OLLAMA
# -----------------------------
if ! command -v ollama &> /dev/null; then
  echo "📦 Instaliram Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
fi

echo "🚀 Pokrećem Ollama servis..."
ollama serve >/dev/null 2>&1 &
sleep 3

echo "📥 Povlačim phi3:mini (lagani model)..."
ollama pull phi3:mini

# -----------------------------
# PYTHON VENV
# -----------------------------
cd ~/brko/backend || exit
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install fastapi uvicorn requests soundfile numpy TTS

# -----------------------------
# SYSTEM PROMPT
# -----------------------------
cat << 'EOF' > system_prompt.txt
Ti si Brko, lokalni glasovni asistent koji radi offline.
Uvijek se predstavljaš kao Brko.

Govoriš prirodno na bosanskom, hrvatskom ili srpskom jeziku.
Tvoj glas je muški, smiren i prijateljski, zove se Srećko.

Govoriš kratko, jasno i bez pauza.
Ne koristiš emotikone.
Ne koristiš specijalne znakove.
Ne koristiš nabrajanja osim ako je nužno.

Odgovori moraju biti spremni za TTS.
Ne koristiš navodnike.
Ne praviš dugačke rečenice.
Ne ponavljaš se.

Pamtiš kontekst razgovora.
Ako te pitaju ko si, kažeš:
Ja sam Brko, tvoj lokalni glasovni asistent.

Radiš u okruženju sa malo RAM memorije.
Uvijek odgovaraš kao Brko.
EOF

# -----------------------------
# CHAT ENGINE
# -----------------------------
cat << 'EOF' > chat_engine.py
import requests

OLLAMA_URL = "http://localhost:11434/api/generate"

with open("system_prompt.txt", "r", encoding="utf-8") as f:
    SYSTEM_PROMPT = f.read()

def ask_brko(text):
    payload = {
        "model": "phi3:mini",
        "prompt": text,
        "system": SYSTEM_PROMPT,
        "stream": False,
        "options": {
            "temperature": 0.4,
            "top_p": 0.9,
            "num_ctx": 2048
        }
    }

    r = requests.post(OLLAMA_URL, json=payload, timeout=120)
    r.raise_for_status()
    return r.json()["response"]
EOF

# -----------------------------
# TTS
# -----------------------------
cat << 'EOF' > tts.py
from TTS.api import TTS
import soundfile as sf
import uuid

tts = TTS(model_name="tts_models/hr/cv/vits", progress_bar=False, gpu=False)

def tts_to_wav(text):
    filename = f"/tmp/brko_{uuid.uuid4().hex}.wav"
    wav = tts.tts(text)
    sf.write(filename, wav, 22050)
    return filename
EOF

# -----------------------------
# MAIN API
# -----------------------------
cat << 'EOF' > main.py
from fastapi import FastAPI, Query
from fastapi.responses import FileResponse
from chat_engine import ask_brko
from tts import tts_to_wav

app = FastAPI()

@app.get("/ask")
def ask(text: str = Query(...)):
    answer = ask_brko(text)
    wav = tts_to_wav(answer)
    return FileResponse(wav, media_type="audio/wav", filename="brko.wav")
EOF

# -----------------------------
# DONE
# -----------------------------
echo "✅ Instalacija završena"
echo "🚀 Pokreni Brku sa:"
echo "source venv/bin/activate"
echo "uvicorn main:app --host 0.0.0.0 --port 8001"
echo ""
echo "🎧 Test:"
echo "ffplay -autoexit \"http://localhost:8001/ask?text=Brko kako si danas\""
