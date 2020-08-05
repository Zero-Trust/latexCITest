#!/bin/bash
set -eux

inputfile=main.tex
outputfile=main.pdf

# build pdf (change if necessary)
ptex2pdf "${inputfile}"

# create release
res=`curl -H "Authorization: token $GITHUB_TOKEN" \
          -X POST https://api.github.com/repos/${GITHUB_REPOSITORY}/releases \
          -d "{
  \"tag_name\": \"v$GITHUB_SHA\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"v$GITHUB_SHA\",
  \"draft\": false,
  \"prerelease\": false
}"`

# extract release id
rel_id=`echo ${res} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

# upload built pdf
curl --header "Authorization: token ${GITHUB_TOKEN}" \
     --header 'Content-Type: application/pdf'        \
     --request POST "https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${rel_id}/assets?name=${outputfile}" \
     --upload-file ${outputfile}

