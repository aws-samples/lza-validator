#!/bin/bash -eu
set -o pipefail

# Recent n releases of LZA
n=1

# Container tooling choice (docker/finch/...)
tooling=docker

# Include experimental releases
exp=0

if [ ! -d landing-zone-accelerator-on-aws ]; then
  git clone https://github.com/awslabs/landing-zone-accelerator-on-aws.git
fi
cd landing-zone-accelerator-on-aws
git checkout main
git pull
if [ $exp -ne 0 ]; then
    tags=$(git tag | sort -V)
else
    tags=$(git tag | sort -V | grep -v experimental)
fi
latest_n_releases=$(echo $tags | rev | cut -d ' ' -f 1-$n | rev)

cd ..

for release in $latest_n_releases; do
  cd landing-zone-accelerator-on-aws
  git -c advice.detachedHead=false checkout $release
  cd ..
  echo $release
  $tooling build --build-arg $release --tag lza-validator:$release .
done
