import subprocess
import tempfile
import os

VOICE = "Srecko"

def tts_to_wav(text: str) -> str:
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    tmp.close()

    subprocess.run(
        [
            "RHVoice-test",
            "-p", VOICE,
            "-o", tmp.name
        ],
        input=text.encode("utf-8"),
        check=True
    )

    return tmp.name
