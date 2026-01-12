#!/bin/bash
set -e

echo "=== BRKO TTS FALLBACK (COQUI) ==="

sudo apt update
sudo apt install -y python3 python3-venv python3-pip ffmpeg

python3 -m venv tts_env
source tts_env/bin/activate

pip install --upgrade pip
pip install TTS==0.22.0

echo "▶ Starting TTS test..."

tts --text "Brko sada koristi alternativni TTS koji radi stabilno." \
    --model_name tts_models/multilingual/multi-dataset/xtts_v2 \
    --out_path /tmp/brko_test.wav

echo "✅ GOTOVO → /tmp/brko_test.wav"
