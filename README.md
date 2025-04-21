# Wordle iMessage stats

If you have an imessage chat where you post wordles, this will give you epic stats

## Setup (for mac)

- `brew install imessage-exporter`
- Open system preferences and enable full disc access for your terminal app
- Restart the terminal
- Run `imessage-exporter -f txt` to export all your iMessages to a folder in your home directory 
- Locate the .txt file for the chat you want to analyze and drag it into this directory and name it "chat.txt"
- Create a file called contacts.json in the root of this directory and add contacts to it in the format:
```json
{
  "Me": "My Name",
  "1111111111": "Somebody with this number",
  "test@test.com": "Somebody with an email"
}
```

- cd into the project directory 
- run `ruby script.rb`

This will output data in the console
```bash
Stats for My Friend:
Total Wordles: 84
Scores:|2:1||3:20||4:39||5:15||6:9|X|0
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

That will produce something like this: 
![CleanShot 2025-04-20 at 20 39 18@2x](https://github.com/user-attachments/assets/64502e97-5e97-4cdc-b29d-21b35bda934e)


