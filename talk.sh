  GNU nano 7.2                         talk.sh                                  
#!/bin/bash

# Configuration
BYTES=50000
SPEED=10.0
FILE1="test1.mp3"
FILE2="test2.mp3"

# Function to generate audio using gTTS
generate_gtts() {
    local output_file=$1
    local byte_count=$2
    head -c $byte_count /dev/random | base64 | tr -d '\n' | \
    python3 -c "import sys; from gtts import gTTS; text=sys.stdin.read(); tts =>
}

# --- Immediate Generation ---
echo "Generating fast initial buffer (small size)..."
# We only use 100 bytes for the first file so it loads instantly
generate_gtts $FILE1 100 
generate_gtts $FILE2 $BYTES

# --- Continuous Loop ---
while true; do
    echo "Playing $FILE1, generating $FILE2..."
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE1 &
    
    # Generate the next file while the current one plays
    generate_gtts $FILE2 $BYTES
    
    wait $!
    
    echo "Playing $FILE2, generating $FILE1..."
    ffplay -nodisp -autoexit -af "atempo=$SPEED" $FILE2 &
    
    generate_gtts $FILE1 $BYTES
    
    wait $!
done
