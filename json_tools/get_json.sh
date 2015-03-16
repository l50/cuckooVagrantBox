#!/bin/bash

## EDIT these paths
CUCKOOUTILS=/cuckoo/utils/
SAMPLEPATH=/cuckoo/samples/

cd $SAMPLEPATH

FILES=./*.bytes

i=1
for f in $FILES
do
  filename=$(basename "$f")
  ext="${filename##*.}"
  filename="${filename%.*}"
  url=http://localhost:8090/tasks/report/$i
  httpcode=`curl -o /dev/null --silent --head --write-out '%{http_code}\n' $url`
  if [ "$httpcode" == '200' ]; then
    echo "Pulling results from $f"
    curl $url > ./json/${filename}.json
    mv $f ./json/processed/
  fi
  i=$[$i+1]
done

cd ./json/
python3 filter_json.py
