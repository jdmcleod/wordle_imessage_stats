# Wordle iMessage stats

If you have an imessage chat where you post wordles, this will give you epic stats

## Setup (for mac)

1. Clone this repository or download the script
2. Make the script executable:
   ```bash
   chmod +x export_chat_history.sh
   ```

3. Run the script:
   ```bash
   ./export_chat_history.sh
   ```
The script will:
   - Check if `imessage-exporter` is installed and install it if needed
   - Export your iMessages to a temporary directory
   - Display a numbered list of all available chat files
Select a chat:
   - You'll see a numbered list of all available chat files
   - Enter the number corresponding to the chat you want to use
   - The script will validate your selection
Results:
   - The selected chat will be copied to `chat.txt` in your current directory
   - All temporary files will be automatically cleaned up
Next steps:
   - Create a `contacts.json` file if you haven't already
   - The `chat.txt` file is ready for further processing

## Note

Make sure you have the necessary permissions to access your iMessage data. On recent macOS versions, you may need to grant Terminal full disk access in System Preferences > Security & Privacy > Privacy > Full Disk Access.

4. Create a file called contacts.json in the root of this directory and add contacts to it in the format:
```json
{
  "Me": "My Name",
  "1111111111": "Somebody with this number",
  "test@test.com": "Somebody with an email"
}
```

5. cd into the project directory
6. run `ruby people_stats.rb` or `ruby word_difficulty.rb`

This will output data in the console
```bash
Stats for My Friend:
Total Wordles: 84
Scores:|2:1||3:20||4:39||5:15||6:9|X:0|
Average score: 4.13
Average greens on first guess: 0.49
Percent greens: 45.13
Percent yellows: 14.87
No yellows: 7
Average hour submitted: 8:39 AM
```

Now add whatever epic stats you want!

Pro tip: Copy and paste the output into the AI of your choice and ask it to make charts for you.

A good prompt for chatGPT:

```
Analyze these world statistics and create a chart with the columns

- Name
- Average score
- Total Wordles
- Most frequent guess
- Amount of times with score of 1
- Amount of times with score of 2
- Amount of losses
- Avg greens/First guess
- Percent greens
- Percent yellows
- Avg time

Statistics: <paste results here>
```

That will produce something like this:
![CleanShot 2025-04-20 at 20 39 18@2x](https://github.com/user-attachments/assets/64502e97-5e97-4cdc-b29d-21b35bda934e)


