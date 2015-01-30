#!/bin/bash

echo "Generating static blog files..."
cd ./blog
hexo generate

echo "Cleaning ./public/blog..."
rm -rf ../public/blog

echo "Copying static blog files to ./public/blog..."
cp -r ./public/ ../public/blog
