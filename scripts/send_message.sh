#!/bin/bash
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

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

# Verify that CHAT_ID is set
if [ -z "$CHAT_ID" ]; then
    echo "[ERROR] CHAT_ID is not set in .env file"
    exit 1
fi

echo "Pulling chat"
scripts/pull_chat.sh

MESSAGE=$(ruby scripts/yesterday.rb)

# uncomment for debugging
#ruby scripts/yesterday.rb > /tmp/ruby_stdout.txt 2> /tmp/ruby_stderr.txt
#MESSAGE=$(< /tmp/ruby_stdout.txt)

echo "Sending message"
echo $MESSAGE

osascript <<END
tell application "Messages"
    set targetService to 1st service whose service type = iMessage
    set targetChat to chat id "$CHAT_ID" of targetService
    send "$MESSAGE" to targetChat
end tell
END
