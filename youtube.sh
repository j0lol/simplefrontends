urlARRAY=()
docurl () {
curl -s --request POST \
  --url 'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8' \
  --header 'Accept: */*' \
  --header 'Accept-Language: en-US,en;q=0.5' \
  --header 'Connection: keep-alive' \
  --header 'Content-Type: application/json' \
  --header 'DNT: 1' \
  --header 'Origin: https://www.youtube.com' \
  --header 'TE: Trailers' \
  --header 'X-Youtube-Client-Name: 1' \
  --data '{
  "context": {
    "client": {
      "clientName": "WEB",
      "clientVersion": "2.20201210.01.00",
      "originalUrl": "https://www.youtube.com/",
      "platform": "DESKTOP",
      "clientFormFactor": "UNKNOWN_FORM_FACTOR",
      "newVisitorCookie": true
    }
  },
  "browseId": "'"$1"'",
  "params": "EgZ2aWRlb3M%3D"
 }' \
  | tee /tmp/capture.out> /dev/null 2>&1 

}

selectVideos() {
  docurl "$1"
RESPONSE=$(cat /tmp/capture.out)

  ytName=$(echo $RESPONSE | jq -r '.header.c4TabbedHeaderRenderer.title')
  ytSubs=$(echo $RESPONSE | jq -r '.header.c4TabbedHeaderRenderer.subscriberCountText.simpleText')

  echo "$ytName"
  echo "$ytSubs"
  echo
for i in {0..29}
do
  # echo "$i"
  ytID=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items['"$i"'].gridVideoRenderer.videoId')
  urlARRAY+=("$ytID")
  ytTitle=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items['"$i"'].gridVideoRenderer.title.runs[0].text' )
  ytTimestamp=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items['"$i"'].gridVideoRenderer.publishedTimeText.simpleText' )

  if [[ "$ytTitle" == "null" ]]
  then
    break
  fi

  echo "$i) $ytTitle — $ytTimestamp"
done

    echo "Type in a video number to open it in MPV, or ^C to exit"
    read REPLY

    #echo ${urlARRAY[$REPLY]}
    #exit

    mpv "https://youtube.com/watch?v=${urlARRAY[$REPLY]}"
}

bold=$(tput bold)
normal=$(tput sgr0)


FOLLOWSDIR="$HOME/.config/"
FOLLOWSNAME="ytsubs"

if [ -s $FOLLOWSDIR$FOLLOWSNAME ]
then

  # Set file as "input"
  input=$FOLLOWSDIR$FOLLOWSNAME

  i=0
  # Iterate through file line by line
    idARRAY=()
    channelARRAY=()
  while IFS= read -r line
  do


    [[ "$line" =~ ^#.*$ ]] && continue

    docurl "$line"

    channelARRAY+=("$line")
    RESPONSE=$(cat /tmp/capture.out)
    ytName=$(echo $RESPONSE | jq -r '.header.c4TabbedHeaderRenderer.title')
    
  ytID=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items[0].gridVideoRenderer.videoId')
  idARRAY+=("$ytID")
  ytTitle=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items[0].gridVideoRenderer.title.runs[0].text' )
  ytTimestamp=$(echo $RESPONSE | jq -r '.contents.twoColumnBrowseResultsRenderer.tabs[1].tabRenderer.content.sectionListRenderer.contents[0].itemSectionRenderer.contents[0].gridRenderer.items[0].gridVideoRenderer.publishedTimeText.simpleText' )
  echo "$i) $bold$ytName$normal"
  echo "Last uploaded: $ytTimestamp"
  echo "$ytTitle"
  echo
  i=$((i+1))
  done < "$input"

  echo "Type [number][selector] to select a channel/video"
  echo "1c will open list view of item 1, 0v will open latest video from item 0, or ^C to exit"
  read REPLY

  if [[ "$REPLY" =~ [0-9]*v ]]
  then
    REPLY=$(echo "$REPLY" | sed -r 's/^[^0-9]*([0-9]+).*$/\1/' )
    mpv "https://youtube.com/watch?v=${idARRAY[$REPLY]}"
    exit
  elif [[ "$REPLY" =~ [0-9]*c ]]
  then
    REPLY=$(echo "$REPLY" | sed -r 's/^[^0-9]*([0-9]+).*$/\1/' )
    clear
    selectVideos "${channelARRAY[$REPLY]}"
    exit
  fi
else

  cd $FOLLOWSDIR
  # Make user setup follows here
  echo "First time setup..."
  echo -e "# Place youtube IDs here, line by line. Lines starting with # are ignored.\n" > $FOLLOWSNAME
  xdg-open $FOLLOWSNAME
  echo "Please re-run after you have finished setting up your follows."
  echo "If you want any other customisations, please edit the script yourself :)"
fi
#selectVideos "UCdoPCztTOW7BJUPk2h5ttXA"
