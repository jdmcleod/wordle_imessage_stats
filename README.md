# Wordle iMessage stats

If you have an imessage chat where you post wordles, this will give you epic stats.

Currently the two available scripts are:
- `stats.rb` - Gives you stats for each person in the chat
- `word_difficulty.rb` - Gives you stats for how hard each word in the chat was

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
6. run `ruby stats.rb` or `ruby word_difficulty.rb`

Stats output: 
![CleanShot 2025-04-24 at 13 43 22@2x](https://github.com/user-attachments/assets/8249a5ed-4dbd-4715-8099-fbc2ea4f3de8)


Word difficulty output: 

![CleanShot 2025-04-24 at 13 45 02@2x](https://github.com/user-attachments/assets/2fa62fcb-b9ba-4198-a084-514175964822)

Now add whatever epic stats you want!
