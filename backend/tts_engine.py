import asyncio
import hashlib
import os
import edge_tts
import subprocess

VOICE = "hr-HR-SreckoNeural"
CACHE_DIR = "cache"

os.makedirs(CACHE_DIR, exist_ok=True)

async def generate_tts(text: str) -> str:
    text = text.strip()
    h = hashlib.md5(text.encode("utf-8")).hexdigest()
    raw_path = f"{CACHE_DIR}/{h}.mp3"
    wav_path = f"{CACHE_DIR}/{h}.wav"

    if os.path.exists(wav_path):
        return wav_path

    communicate = edge_tts.Communicate(
        text=text,
        voice=VOICE,
        rate="+0%",
        volume="+0%"
    )

    await communicate.save(raw_path)

    # konverzija u STABILAN WAV
    subprocess.run(
        [
            "ffmpeg", "-y",
            "-i", raw_path,
            "-ac", "1",
            "-ar", "44100",
            "-sample_fmt", "s16",
            wav_path
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=True
    )

    return wav_path
