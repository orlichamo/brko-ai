#!/bin/bash
set -e

echo "🧠 Brko Docker setup započet..."

# Provjera Dockera
if ! command -v docker &> /dev/null; then
  echo "🐳 Instaliram Docker..."
  sudo apt update
  sudo apt install -y docker.io docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
  echo "⚠️ Odjavi se i ponovo prijavi da Docker radi bez sudo!"
fi

mkdir -p brko_docker
cd brko_docker

# Dockerfile
cat > Dockerfile <<EOF
FROM python:3.11-slim

WORKDIR /app

RUN apt update && apt install -y \\
    ffmpeg \\
    libsndfile1 \\
    git \\
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# requirements
cat > requirements.txt <<EOF
fastapi
uvicorn
requests
soundfile
numpy
TTS==0.22.0
EOF

# main.py
cat > main.py <<EOF
from fastapi import FastAPI, Query
from fastapi.responses import FileResponse
import requests
import uuid
from TTS.api import TTS

app = FastAPI()

tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")

def ask_brko(text):
    r = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "phi3:mini",
            "prompt": text,
            "stream": False
        }
    )
    return r.json()["response"]

@app.get("/ask")
def ask(text: str = Query(...)):
    answer = ask_brko(text)

    filename = f"/tmp/{uuid.uuid4()}.wav"
    tts.tts_to_file(text=answer, file_path=filename, language="hr")

    return FileResponse(filename, media_type="audio/wav", filename="brko.wav")
EOF

echo "🐳 Buildam Docker image..."
docker build -t brko .

echo "✅ Gotovo!"
echo "▶️ Pokreni sa: docker run -p 8000:8000 --rm brko"
