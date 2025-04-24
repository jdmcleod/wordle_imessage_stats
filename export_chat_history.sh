#!/bin/bash

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

# Find all .txt files in the exported directory
echo "Available chat files:"
find "$temp_dir" -name "*.txt" | nl

# Ask user to select a file
echo -n "Enter the number of the chat file you want to use: "
read selection

# Get the selected file
selected_file=$(find "$temp_dir" -name "*.txt" | sed -n "${selection}p")

if [ -z "$selected_file" ]; then
    echo "Invalid selection"
    rm -rf "$temp_dir"
    exit 1
fi

# Copy the selected file to the current directory as chat.txt
cp "$selected_file" "./chat.txt"

# Clean up
rm -rf "$temp_dir"

echo "Chat file has been copied to ./chat.txt"
echo "Don't forget to create contacts.json if you haven't already!"