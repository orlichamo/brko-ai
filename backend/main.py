from fastapi import FastAPI, Query
from fastapi.responses import FileResponse, JSONResponse
import subprocess
import uuid
import os

app = FastAPI(title="Brko TTS Backend")

TMP_DIR = "/tmp"
VOICE = "hr"        # espeak-ng Croatian (najbliže Srećki bez Piper-a)
SPEED = "140"       # brzina govora (120–160 je sweet spot)
PITCH = "50"        # neutralna visina glasa


@app.get("/")
def health():
    return {"status": "Brko je ziv i prica 🇭🇷"}


@app.post("/tts")
def tts(
    text: str = Query(..., min_length=1, max_length=500)
):
    try:
        filename = f"{TMP_DIR}/{uuid.uuid4()}.wav"

        cmd = [
            "espeak-ng",
            "-v", VOICE,
            "-s", SPEED,
            "-p", PITCH,
            "-w", filename,
            text
        ]

        subprocess.run(cmd, check=True)

        return FileResponse(
            filename,
            media_type="audio/wav",
            filename="brko.wav"
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

