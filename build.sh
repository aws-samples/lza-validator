#!/bin/bash -eu
set -o pipefail

# Recent n releases of LZA
n=1

# Container tooling choice (docker/finch/...)
tooling=docker

if [ ! -d landing-zone-accelerator-on-aws ]; then
  git clone https://github.com/awslabs/landing-zone-accelerator-on-aws.git
fi
cd landing-zone-accelerator-on-aws
git checkout main
git pull
tags=$(git tag)
latest_n_releases=$(echo $tags | rev | cut -d ' ' -f 1-$n | rev)
cd ..

for release in $latest_n_releases; do
  cd landing-zone-accelerator-on-aws
  git -c advice.detachedHead=false checkout $release
  cd ..
  $tooling build -t lza-validator:$release .
done


