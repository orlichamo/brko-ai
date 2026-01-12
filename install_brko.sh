#!/bin/bash
set -e

echo "=== BRKO AI INSTALLER ==="

echo "[1/7] Updating system..."
sudo apt update -y
sudo apt install -y docker.io docker-compose-plugin git curl

echo "[2/7] Enabling Docker service..."
sudo systemctl enable docker --now

echo "[3/7] Adding user to docker group..."
sudo usermod -aG docker $USER

echo "[4/7] Creating directories..."
mkdir -p ~/brko/piper-data

echo "[5/7] Creating docker-compose.yml..."
cat << 'EOF' > ~/brko/docker-compose.yml
version: "3.9"

services:
  stt:
    image: lscr.io/linuxserver/whisper-asr:latest
    container_name: whisper
    ports:
      - "10300:10300"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Vienna
      - WHISPER_MODEL=small
    restart: unless-stopped

  tts:
    image: rhasspy/wyoming-piper:latest
    container_name: piper
    ports:
      - "10200:10200"
    volumes:
      - ./piper-data:/data
    restart: unless-stopped

  brko:
    image: ghcr.io/orlichamo/brko-ai:latest
    container_name: brko
    ports:
      - "8080:8080"
    environment:
      - STT_URL=http://stt:10300
      - TTS_URL=http://tts:10200
    depends_on:
      - stt
      - tts
    restart: unless-stopped
EOF

echo "[6/7] Pulling images..."
cd ~/brko
docker compose pull

echo "[7/7] Starting BRKO AI..."
docker compose up -d

echo ""
echo "=================================="
echo " BRKO AI INSTALLED & RUNNING!"
echo "----------------------------------"
echo " STT:  http://localhost:10300"
echo " TTS:  http://localhost:10200"
echo " BRKO: http://localhost:8080"
echo "=================================="
