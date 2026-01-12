#!/bin/bash
set -e

echo "=== BRKO → PIPER (hr_HR_Srecko) AUTO SETUP ==="

BASE=~/brko/backend/piper
BIN=$BASE/bin
VOICES=$BASE/voices/hr

mkdir -p "$BIN" "$VOICES"

echo "▶ Download Piper binary..."
wget -q https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz -O /tmp/piper.tar.gz

tar -xzf /tmp/piper.tar.gz -C /tmp
mv /tmp/piper/piper "$BIN/piper"
chmod +x "$BIN/piper"

echo "▶ Download hr_HR_Srecko (medium)..."
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/hr/hr_HR/srecko/medium/hr_HR-srecko-medium.onnx \
     -O "$VOICES/hr_HR-srecko.onnx"

wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/hr/hr_HR/srecko/medium/hr_HR-srecko-medium.onnx.json \
     -O "$VOICES/hr_HR-srecko.onnx.json"

echo "▶ Test synthesis..."
echo "Brko je uspješno prebačen na Piper." | \
"$BIN/piper" \
  --model "$VOICES/hr_HR-srecko.onnx" \
  --output_file /tmp/brko_test.wav \
  --sentence_silence 0.2 \
  --length_scale 1.05

echo "✅ GOTOVO"
echo "Audio test: /tmp/brko_test.wav"
