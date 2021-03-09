#!/bin/bash

function build {
  npm run build:lib
}

function updateVersion {
    pushd projects/ngx-img-cropper
    echo "New version change: $newVersion"
    oldVersionValue=$(cat package.json | grep version | grep -oP "\d+[^\"]+")
    npm version "$newVersion"
    newVersionValue=$(cat package.json | grep version | grep -oP "\d+[^\"]+")
    echo "New version value: $newVersionValue - from $oldVersionValue"
    popd
}

newVersion="$1"
if [ -z "$newVersion" ]; then
    newVersion="prerelease"
fi

git status | grep 'nothing to commit'
if [ $? -eq 1 ]; then
    echo 'Commit everything before running update script.';
    exit 1
fi

# git pull origin master
updateVersion
build || exit 2

git status | grep 'nothing to commit'
if [ $? -eq 1 ]; then
    git add -A && git commit -m "dump release files"
fi
git push

pushd dist/ngx-img-cropper
npm publish
popd
