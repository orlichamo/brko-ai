#!/bin/bash

set -e

echo "🧠 Brko LocalAI setup pokrećem..."

# 1️⃣ Provjera Dockera
if ! command -v docker &> /dev/null; then
    echo "❌ Docker nije instaliran!"
    exit 1
fi

# 2️⃣ Obriši stari container ako postoji
if docker ps -a | grep -q localai; then
    echo "🧹 Brišem postojeći localai container..."
    docker rm -f localai
fi

# 3️⃣ Pokreni LocalAI
echo "🚀 Pokrećem LocalAI container..."
docker run -d \
  --name localai \
  -p 8080:8080 \
  ghcr.io/go-skynet/local-ai:latest

# 4️⃣ Sačekaj da se digne
echo "⏳ Čekam da se LocalAI podigne..."
sleep 10

# 5️⃣ Instaliraj model
echo "📦 Instaliram llama-2-7b-chat model..."
docker exec localai local-ai models install llama-2-7b-chat

# 6️⃣ Test API
echo "🧪 Testiram API..."
curl -s http://localhost:8080/v1/models | grep llama || {
    echo "❌ Model nije učitan!"
    exit 1
}

echo "✅ LOCALAI JE SPREMAN!"
echo "👉 API: http://localhost:8080/v1/chat/completions"
