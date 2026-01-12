from fastapi import FastAPI, Query
from fastapi.responses import FileResponse, JSONResponse
from TTS.api import TTS
import uuid
import os

app = FastAPI(
    title="Brko TTS Backend",
    version="0.1.0"
)

# Cache model u /tmp (Render dozvoljava)
TTS_MODEL = "tts_models/en/ljspeech/tacotron2-DDC"

tts = TTS(model_name=TTS_MODEL, progress_bar=False, gpu=False)

@app.get("/")
def health():
    return "Brko je živ i priča 🇭🇷"

@app.post("/tts")
def tts_endpoint(
    text: str = Query(..., min_length=1, max_length=500)
):
    try:
        filename = f"/tmp/brko_{uuid.uuid4().hex}.wav"

        tts.tts_to_file(
            text=text,
            file_path=filename
        )

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

