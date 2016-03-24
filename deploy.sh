#!/bin/bash
set -ue

dir="tmp/$(uuidgen)"
rm -rf "$dir"
git clone --depth 1 https://github.com/blogsed/blogsed.github.io "$dir"
cp .env "$dir"
cd "$dir"
git config user.name "The BLOGS Deployment Robot"
git config user.email "deploy@blogs.org.uk"
git remote set-url origin git@github.com:blogsed/blogsed.github.io
_script/update_events.sh
_script/deploy.sh
rm -rf "$dir"
