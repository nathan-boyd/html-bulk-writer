#!/bin/bash

# creates an html page per mp3 file in directory

##### Functions

function write_html
{
    filename=$1
    file=$2
    clean_string=$3
    html_filename=$clean_string
    new_filename=$clean_string

    if [ ! -d ./output ]; then
        mkdir -p ./output;
    fi

    if [ ! -d ./output/audiofiles ]; then
        mkdir -p ./output/audiofiles;
    fi

    cp $file ./output/audiofiles/${new_filename}.mp3

    cat <<- _EOF_ > ./output/${html_filename}.html
        <!DOCTYPE html>
        <html lang="en-US">
        <head>
          <title>$filename</title>
          <link href='http://fonts.googleapis.com/css?family=Bree+Serif' rel='stylesheet' type='text/css'>
          <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
          <link rel="stylesheet" type="text/css" href="styles/main.css">
        </head>
        <body>
          <div class="wrapper">
            <div class="holder">
              <h1>${filename}</h1>
              <audio controls autoplay>
                <source src="audiofiles/${new_filename}.mp3" type="audio/mpeg">
                  Your browser does not support the audio element.
              </audio>
            </div>
          </div>
        </body>
      </html>
_EOF_

}

write_css() {
  if [ ! -d ./output/styles ]; then
      mkdir -p ./output/styles;
  fi

  cat <<- _EOF_ > ./output/styles/main.css
      h1 {
        font: 500 60px/1.3 'Bree Serif', Georgia, serif;
        color: green
      }

      .wrapper {
          display: table;
          width: 100%;
          height: 400px;
      }

      .holder {
          text-align: center;
          display: table-cell;
          vertical-align: middle;
      }

      audio {
         min-height: 200px;
         min-width: 800px;
      }
_EOF_

}

url_encode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  ENCODED="${encoded}"
}

create_qr_code()
{
    resource_url=$1
    fileName=$2
    curl -s -o ./qr_codes/${filename}.png https://api.qrserver.com/v1/create-qr-code/?data=${resource_url}&size=500x500
}

clean_string()
{
    CLEAN_STRING=${1//[^[:alnum:]]/}
}

function process_directory
{
    IFS=$'\n';
    for file in $(find $1 -name '*.mp3');
    do
        filename="${file%.*}"
        filename="${filename##*/}"

        echo $filename
        clean_string $filename

        url_encode $CLEAN_STRING
        url=http://engineernathan.org/mrsboydclassroom/audiobooks/${ENCODED}.html

        create_qr_code $url $filename
        write_html $filename $file $CLEAN_STRING
    done
}

if [ "$1" != "" ]; then
    write_css
    process_directory $1
    zip -r ./erika_output.zip ./output*
    echo "Done."
else
    echo "Path to input directory required."
fi
