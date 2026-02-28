import os
import subprocess
import threading
import queue
import time
import io
from gtts import gTTS

# --- CONFIGURATION ---
SPEED = 20.0       # Your requested high speed
CHUNK_CHARS = 1000 # More characters = longer audio = more time for API to catch up
BUFFER_SIZE = 2   # How many chunks to download before starting
# ---------------------

audio_queue = queue.Queue()

def producer():
    """Background worker: Grabs random text and fetches MP3s from Google."""
    while True:
        # Generate printable random text
        raw_bytes = os.urandom(CHUNK_CHARS)
        text = "".join([chr(b) for b in raw_bytes if 32 <= b <= 126])
        
        try:
            mp3_io = io.BytesIO()
            tts = gTTS(text=text, lang='en')
            tts.write_to_fp(mp3_io)
            audio_queue.put(mp3_io.getvalue())
        except Exception:
            time.sleep(1) # Wait on network error

def consumer():
    """Main worker: Feeds ffplay the buffered audio."""
    # Wait until the buffer is healthy to prevent immediate stutter
    print(f"Buffering... (Waiting for {BUFFER_SIZE} segments)")
    while audio_queue.qsize() < BUFFER_SIZE:
        time.sleep(0.5)
    
    print("Buffer ready! Starting playback...")
    
    # Open ffplay ONCE. We use the 'mp3' format flag for a continuous stream.
    player = subprocess.Popen(
        ['ffplay', '-nodisp', '-autoexit', '-af', f'atempo={SPEED}', '-f', 'mp3', '-i', 'pipe:0'],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    try:
        while True:
            chunk = audio_queue.get()
            player.stdin.write(chunk)
            player.stdin.flush()
    except (BrokenPipeError, KeyboardInterrupt):
        player.terminate()

# Start the background downloader
threading.Thread(target=producer, daemon=True).start()

# Run the player
consumer()
