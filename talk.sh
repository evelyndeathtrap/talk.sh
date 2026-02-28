#!/bin/bash

# Configuration - Increased bytes for fewer requests, lower speed for stability
BYTES=5000
SPEED=10.0
FILE1="test1.mp3"
FILE2="test2.mp3"
FILE3="test3.mp3"

# Function to generate audio
generate_audio() {
    local output_file=$1
    # Increased BYTES ensures more text per request, less frequent gaps
    head -c $BYTES /dev/urandom | tr -dc 'a-zA-Z0-9 ' | \
    python3 -c "import sys; from gtts import gTTS; text=sys.stdin.read(); tts = gTTS(text, lang='en'); tts.save('$output_file')"
}

# --- Initial Generation (Triple Buffer) ---
echo "Generating initial buffers... this may take a moment."
generate_audio $FILE1
generate_audio $FILE2
generate_audio $FILE3

# --- Continuous Loop ---
while true; do
    # Play files in sequence, generating the next one while the current plays
    
    # 1. Play 1, generate 3
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE1 &
    generate_audio $FILE3
    wait $!

    # 2. Play 2, generate 1
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE2 &
    generate_audio $FILE1
    wait $!
    
    # 3. Play 3, generate 2
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE3 &
    generate_audio $FILE2
    wait $!
done
