import asyncio
import edge_tts

async def main():
    communicate = edge_tts.Communicate(
        text="Zdravo Hamo. Ja sam Brko. Ovo je čisti test bez pauza i bez šuma.",
        voice="hr-HR-SreckoNeural",
        rate="+0%",
        pitch="+0Hz"
    )
    await communicate.save("brko_raw.mp3")

asyncio.run(main())
