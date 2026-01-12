from fastapi import FastAPI, Query
from fastapi.responses import FileResponse, JSONResponse
import uuid
import os

app = FastAPI(title="Brko TTS Backend", version="0.1.0")

AUDIO_DIR = "audio"
os.makedirs(AUDIO_DIR, exist_ok=True)

tts = None

def load_tts():
    global tts
    if tts is None:
        from TTS.api import TTS
        tts = TTS(
            model_name="tts_models/en/vctk/vits",
            progress_bar=False,
            gpu=False
        )

@app.get("/")
def health():
    return "Brko je ziv i prica 🇭🇷"

@app.post("/tts")
def tts_endpoint(
    text: str = Query(..., min_length=1, max_length=500)
):
    try:
        load_tts()

        filename = f"{uuid.uuid4()}.wav"
        filepath = os.path.join(AUDIO_DIR, filename)

        tts.tts_to_file(text=text, file_path=filepath)

        return FileResponse(
            filepath,
            media_type="audio/wav",
            filename="brko.wav"
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )
<<<<<<< HEAD
=======


>>>>>>> b2f0a3d (Fix Render deploy: Python 3.10 + Coqui TTS)
