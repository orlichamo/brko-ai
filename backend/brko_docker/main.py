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
