#!/bin/bash

#constants (as if bash had them)
TWITCHURL="https://twitch.tv/"
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
FOLLOWSDIR="$HOME/.config/"
FOLLOWSNAME="twitchfollows"

# array
ARRAY=()

docurl () {

  if [ -z "$1" ] ; then echo "Please enter a value";exit; fi

  curl -s --request POST \
    --url https://gql.twitch.tv/gql \
    --header 'Accept: application/json' \
    --header 'Accept-Language: en-US' \
    --header 'Client-Id: r8s4dac0uhzifbpu9sjdiwzctle17ff' \
    --header 'Connection: keep-alive' \
    --header 'Content-Type: application/json' \
    --header 'DNT: 1' \
    --header 'Origin: https://m.twitch.tv' \
    --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0' \
    --header 'X-Device-Id: SBCCPwRDjdL4rAQ8KYngLGUu9NECqlM6' \
    --data '{"query":"query ChannelProfile_Query($login: String!) {\n  channel: user(login: $login) {\n    ...ChannelInfoCard_user\n    ...ChannelProfileVideos_user\n    id\n    login\n    displayName\n    stream {\n      id\n    }\n    hosting {\n      id\n      __typename\n      login\n      stream {\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment ChannelInfoCard_user on User {\n  displayName\n  hosting {\n    id\n  }\n  stream {\n    type\n  }\n}\n\nfragment ChannelProfileVideos_user on User {\n  ...FeaturedContentCard_user\n  login\n  displayName\n  stream {\n     game {\n        name\n      }\n    title\n  }\n  hosting {\n    id\n  }\n}\n\nfragment FeaturedContentCard_user on User {\n  displayName\n  \n  hosting {\n    id\n    login\n    displayName\n    stream {\n      type\n      title\n      game {\n        name\n        id\n      }\n      id\n    }\n  }\n}","variables":{"login":"'"$1"'"},"operationName":"ChannelProfile_Query"}' \
    | tee /tmp/capture.out> /dev/null 2>&1 



  # Optional anti-ratelimit
  #sleep 0.5
}

# Check if file exists
if [ -s $FOLLOWSDIR$FOLLOWSNAME ]
then

  # Set file as "input"
  input=$FOLLOWSDIR$FOLLOWSNAME

  # Iterate through file line by line
  while IFS= read -r line
  do
    
    [[ "$line" =~ ^#.*$ ]] && continue


    ARRAY+=("$(echo $RESPONSE | jq -r '.data.channel.displayName')")

    # cURL request
    docurl "$line"

    # get response from tmpfile (please dont bully me i cant string interp.)
    RESPONSE=$(cat /tmp/capture.out)

    # debug: print response
    #cat /tmp/capture.out

    # If stream type is not null (is live)
    if echo $RESPONSE | jq -e -r '.data.channel.stream.type'> /dev/null 2>&1;
    then

      if echo $RESPONSE | jq -e -r '.data.channel.stream.game.name'> /dev/null 2>&1; then
        echo -e "$GREEN$(echo $RESPONSE | jq -r '.data.channel.displayName')$NC is playing $(echo $RESPONSE | jq -e -r '.data.channel.stream.game.name')";
      else
        echo -e "$GREEN$(echo $RESPONSE | jq -r '.data.channel.displayName')$NC is live";
      fi

      echo $RESPONSE | jq -r '.data.channel.stream.title';   

    elif echo $RESPONSE | jq -e -r '.data.channel.hosting.id'> /dev/null 2>&1;
    then

      if echo $RESPONSE | jq -e -r '.data.channel.hosting.stream.game.name'> /dev/null 2>&1; then
        echo -e "$YELLOW$(echo $RESPONSE | jq -r '.data.channel.displayName')$NC is hosting $(echo $RESPONSE | jq -e -r '.data.channel.hosting.displayName') ($(echo $RESPONSE | jq -e -r '.data.channel.hosting.stream.game.name'))";
      else
        echo -e "$YELLOW$(echo $RESPONSE | jq -r '.data.channel.displayName')$NC is hosting $(echo $RESPONSE | jq -e -r '.data.channel.hosting.displayName')";
      fi

      echo $RESPONSE | jq -r '.data.channel.hosting.stream.title';   
      # If stream type is null (is offline)
    else echo -e "$RED$(echo $RESPONSE | jq -r '.data.channel.displayName')$NC is offline"; fi

    # Extra newline to look nice :)
    echo

    # end of file loop
  done < "$input"
  
  # Edit MPV for another video player if you like,
  # you may have to mess around somehow, though
  # this part uses the youtube-dl addon in mpv to
  # pull the stream directly. This just feeds it as
  # mpv https://twitch.tv/[USER]
  if ! command -v rlwrap &> /dev/null
	then
    echo "Please install rlwrap for tab completion."
    echo "Type in a streamer to open MPV, or ^C to exit"
    read REPLY
else
	REPLY=$(rlwrap -S 'Type in a streamer to open MPV (press tab for auto-complete): ' -e '' -i -f <(echo "${ARRAY[@]}") -o cat)

fi

  echo

  # string inty polatio 
  fulllink=$TWITCHURL$REPLY
  mpv $fulllink
  
  
else

  cd $FOLLOWSDIR
  # Make user setup follows here
  echo "First time setup..."
  echo -e "# Place usernames here, line by line. Lines starting with # are ignored.\n" > $FOLLOWSNAME
  xdg-open $FOLLOWSNAME
  echo "Please re-run after you have finished setting up your follows."
  echo "If you want any other customisations, please edit the script yourself :)"
fi
