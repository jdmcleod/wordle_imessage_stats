#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    echo "[INFO] Loading environment variables..."
    set -a
    source .env
    set +a
else
    echo "[ERROR] .env file not found!"
    exit 1
fi

# Verify that CHAT_NAME is set
if [ -z "$CHAT_NAME" ]; then
    echo "[ERROR] CHAT_NAME is not set in .env file"
    exit 1
fi

# Check if imessage-exporter is installed
if ! command -v imessage-exporter &> /dev/null; then
    echo "imessage-exporter is not installed. Installing via brew..."
    brew install imessage-exporter
fi

# Create a temporary directory
temp_dir=$(mktemp -d)

# Run imessage-exporter
echo "Exporting iMessages to temporary directory..."
imessage-exporter -f txt -o "$temp_dir"

# Check if export was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to export iMessages"
    rm -rf "$temp_dir"
    exit 1
fi

# uncomment this to debug
#echo "Available chat files:"
#find "$temp_dir" -name "*.txt" | nl

# Read chat name from file
echo "Searching for '$CHAT_NAME' chat..."
wordlers_file=$(find "$temp_dir" -type f -name "*$CHAT_NAME*" | head -n 1)

if [ -z "$wordlers_file" ]; then
    echo "Error: Could not find chat containing '$CHAT_NAME'"
    rm -rf "$temp_dir"
    exit 1
fi

# Copy the found file to the current directory as chat.txt
cp "$wordlers_file" "./data/chat.txt"

# Clean up
rm -rf "$temp_dir"

echo "Chat file has been copied to ./data/chat.txt"
echo "Don't forget to create contacts.json if you haven't already!"
