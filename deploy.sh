#!/bin/bash
set -ue

rm -rf tmp/blogsed.github.io
git clone --depth 1 https://github.com/blogsed/blogsed.github.io tmp/blogsed.github.io
cp .env tmp/blogsed.github.io
cd tmp/blogsed.github.io
git config user.name "The BLOGS Deployment Robot"
git config user.email "deploy@blogs.org.uk"
git remote set-url origin git@github.com:blogsed/blogsed.github.io
_script/update_events.sh
_script/deploy.sh
