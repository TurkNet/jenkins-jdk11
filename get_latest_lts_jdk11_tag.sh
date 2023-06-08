#!/bin/bash

url="https://hub.docker.com/v2/repositories/jenkins/jenkins/tags"
page_size=100
page=1
latest_tag=""

while true; do
  response=$(curl -s "$url/?page=$page&page_size=$page_size")
  tags=$(echo "$response" | jq -r '.results[].name')
  
  for tag in $tags; do
    if [[ "$tag" == *"-lts-jdk11" && "$tag" > "$latest_tag" ]]; then
      latest_tag=$tag
    fi
  done

  if [[ $(echo "$response" | jq -r '.next') == "null" ]]; then
    break
  fi
  
  page=$((page + 1))
done

echo "Latest LTS JDK11 Tag: $latest_tag"

# Dockerfile içindeki FROM komutunu güncelleme
sed "s/FROM jenkins\/jenkins:.*/FROM jenkins\/jenkins:$latest_tag/" Dockerfile > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile
