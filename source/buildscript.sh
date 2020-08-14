#!/bin/bash

hugo -d ../ -t hugo-theme-codex
cd ..
git add . 
git commit -m "Updated blog"
git push 


