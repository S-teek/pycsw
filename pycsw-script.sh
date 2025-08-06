#!/bin/bash

cd catalog-scripts
mkdir output

export HOSTNAME="https://dar.elter-ri.eu"
export PAGE=1
export SIZE=200


while true; do
  echo "Fetching page $PAGE..."
  RESPONSE=$(curl -s -G "${HOSTNAME}/api/external-datasets/" \
    --data-urlencode "page=${PAGE}" \
    --data-urlencode "size=${SIZE}" \
    --data-urlencode "sort=newest" \
    -H "Accept: text/xml")

  echo $PAGE
  if [ -z "$RESPONSE" ] || ! echo "$RESPONSE" | grep -q "<gmd"; then
    echo "No more data. Stopping."
    break
  fi

  echo "$RESPONSE" > "input.xml"
  python3 /home/pycsw/pycsw/catalog-scripts/xml_extract/main.py
  # python3 /home/steek/repa/pycsw/catalog-scripts/xml_extract/main.py

  pycsw-admin.py load-records -c ~/pycsw/docker/compose/pycsw.yml -p output/



  PAGE=$((PAGE + 1))
done
