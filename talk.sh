#!/bin/bash

# Configuration
BYTES=2048
SPEED=20.0
FILE1="test1.mp3"
FILE2="test2.mp3"

# Function to generate audio
generate_audio() {
    local output_file=$1
    head -c $byte_count /dev/urandom | tr -dc 'a-zA-Z0-9 ' | \
    python3 -c "import sys; from gtts import gTTS; text=sys.stdin.read(); tts = gTTS(text[:$BYTES], lang='en'); tts.save('$output_file')"
}

# --- Initial Generation ---
echo "This makes your computer verbalize the information that it's processing."
echo "Generating initial buffers..."
generate_audio $FILE1
generate_audio $FILE2

# --- Continuous Loop ---
while true; do
    # Play File 1 in background
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE1 &
    
    # While File 1 plays, regenerate File 2 in foreground
    generate_audio $FILE2
    
    # Wait for File 1 player to finish
    wait $!
    
    # --- Swap files ---
    # Play File 2 in background
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE2 &
    
    # While File 2 plays, regenerate File 1 in foreground
    generate_audio $FILE1
    
    # Wait for File 2 player to finish
    wait $!
done
