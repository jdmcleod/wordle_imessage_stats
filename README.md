# Wordle iMessage stats

If you have an imessage chat where you post wordles, this will give you epic stats.

How cool would it be to have a message like this posted to your chat every day AUTOMATICALLY?

```
⏰ Today's Wordle (1408, WEEDY) was harder than 93% of all 138 chat Wordles
🎯 Chat averaged 4.86 (NYT average of 4.5)
🟩🟩🟩🟩⬜ 7/8 attempts
🔥 Most impressive guess was from Simba
👏 Luckiest first guess was Bentley
```

Well, this explains how to do that. It would be good if you knew some ruby and basic mac terminal commands.

## Setup (for mac)

1. Clone this repository

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Make two scripts executable:
   ```bash
   chmod +x scripts/pull_chat.sh
   ```
   
   ```bash
   chmod +x scripts/send_message.sh
   ```

4. Make sure you have the necessary permissions enabled for your terminal app. On recent macOS versions, you may need to grant Terminal full disk access in System Preferences > Security & Privacy > Privacy > Full Disk Access.

5. Get your iMessage chat ID by running this applescript inside the Script Editor program. You may need to do some trial and error to determine if you have the correct chat ID, but it will be the one with the correct phone numbers.

```
tell application "Messages"
	set allChats to chats
	repeat with c in allChats
		log "======================="
		log "Chat ID: " & id of c
		try
			repeat with p in participants of c
				log "Participant: " & handle of p
			end repeat
		on error errMsg
			log "Error getting participants: " & errMsg
		end try
	end repeat
end tell
```

6. Create a `.env` file in the root of this directory and add the following data: 

```
CHAT_ID="paste iMessage chat id"
CHAT_NAME="Your iMessage chat name"
CONTACTS='{
  "Me": "Your name",
  "10000000" :"Your friend's name",
  "otherfriend@test.com": "Your other friend's name"}'
}'
```

7. To pull your chat data, run `scripts/pull_chat.sh`

## Boom. Now you are set up and ready to roll. 

Here are the scripts you can run:

1. `scripts/stats.rb`
This will generate a table of wordle stats by player for the entire history of the chat. 
   ![CleanShot 2025-04-27 at 21 24 41@2x](https://github.com/user-attachments/assets/08e7c40a-fa6c-43e4-8834-38f35293d022)

2. `scripts/today.rb`
Pull Today's Wordle and display stats for it.

3. `scripts/yesterday.rb`
Pull Yesterday's Wordle and display stats for it.

4`scripts/word_difficulty.rb`
Outputs all the words in the chat and their difficulty. Also outputs the most impressive guessers.

5`scripts/send_message.rb`
This will send a message to your iMessage chat with the wordle stats for the day. You can configure it to run automatically by adding it to your crontab.

Open cron tab editor:
```bash
crontab -e
```

Add the following line to to run the script every day at 7am:
```bash
0 7 * * * /Users/youraccount/Workspace/path/to/scripts/send_message.sh
```

Feel free to customize the script to your liking and add any stats. 

Now, you can feel better about yourself when a word is really difficult. 
