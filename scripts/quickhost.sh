#!/bin/bash

function quickshare() {
    # Config
    PORT=8000
    FOLDER="."  # Serve current directory

    # Get local IP address (first non-loopback address)
    # IP=$(hostname -I | awk '{print $1}')
    IP=$(ipconfig getifaddr en0 2>/dev/null || ip route get 1 | awk '{print $7}' | head -1)
    URL="http://$IP:$PORT"

    # Check if qrencode is installed
    if ! command -v qrencode &> /dev/null; then
        echo "❌ 'qrencode' not found. Install it with:"
        echo "   - macOS: brew install qrencode"
        echo "   - Ubuntu: sudo apt install qrencode"
        echo "   - Arch: sudo pacman -S qrencode"
        exit 1
    fi

    # Start server in background
    echo "🌐 Serving '$FOLDER' at: $URL"
    echo "📱 Scan the QR code below to open on your phone:"
    qrencode -t ANSIUTF8 "$URL"

    # Start Python server
    echo "🚀 Starting Python HTTP server..."
    cd "$FOLDER"
    python3 -m http.server "$PORT"

    # On Ctrl+C, server exits
}
