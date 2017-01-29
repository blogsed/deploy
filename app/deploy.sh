#!/bin/bash
set -ue

if [ "$(uname)" == "Linux" ]; then
  tar --strip-components=2 -xf vendor/git/git.x86_64.tar.gz -C /tmp
  tar --strip-components=2 -xf vendor/curl/curl.x86_64.tar.gz -C /tmp
  PATH="/tmp/bin:$PWD/jq/jq:$PATH"
fi

dir="/tmp/$(uuidgen)"
rm -rf "$dir"
git clone --depth 1 \
  "https://alyssais:$GITHUB_PASSWORD@github.com/blogsed/blogsed.github.io" \
  "$dir"
if [ -f '.env' ]; then
  cp .env "$dir"
fi
cd "$dir"
git config user.name "The BLOGS Deployment Robot"
git config user.email "deploy@blogs.org.uk"
_script/update_events.sh
_script/deploy.sh
rm -rf "$dir"
