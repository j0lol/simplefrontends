# Simple frontends
(Trying to) create simple, CLI frontends for video websites and stuff
(just dont look at the code, its messy)

## Why?
Using official websites suck, and third party clients also suck so i made my own
## twitch.sh

Gets status of twitch streamers (listed line by line in a text file) and displays them in a simple CLI. Lets you open their stream in MPV quickly.

## Features
- Shows when channels are live, hosting or offline!
- Autocomplete usernames!
- Uses twitch's web api (no oauth!)
- Does not use any login!
- Badly programmed!
- Opens in your favourite video editor (as long as its mpv!)
- Might not work on your setup!

![](https://raw.githubusercontent.com/j0lol/simplefrontends/main/twitchscreenshot.png)

### Todo
- Figure out how to make a GUI then port this to pinephone? would be neat

## youtube.sh

Gets "subscribed" channels and lists them, and lets you watch their latest, or older videos (31st+ will be supported in the future)

![](https://media.discordapp.net/attachments/675257567219548160/787350025285271572/ytchannels.png)
![](https://media.discordapp.net/attachments/675257567219548160/787350026779230248/ytvideos.png)

## Features
- Shows latest video, with name and upload time
- Lets you browse previous videos
- Uses youtube's web api (no oauth)
- Does not have logins
- Might not work on your setup!

### Todo
- Steal more videos from "load more" request
