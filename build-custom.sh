#!/usr/bin/env bash
set -eo pipefail

# Container tooling choice (docker/finch/...)
TOOLING=${CONTAINER_ENGINE:-podman}

# Clone using SSH or HTTPS
GIT_CLONE_METHOD=${GIT_CLONE_METHOD:-ssh}

echo -e "\n==> Using container tooling: ${TOOLING^}"

RM_IMG_BEFORE_BUILD="false"
for ARG in "$@"; do
	if [[ $ARG == "--rm-img-before-build" ]]; then
		RM_IMG_BEFORE_BUILD="true"
		shift
		break
	fi
done

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [--rm-img-before-build] <lza_release_tag>" >&2
  exit 1
fi
REL_TAG="$1"

set -u

LZA_DIR="landing-zone-accelerator-on-aws"
IMG_NAME="lza-validator"

if [[ ! -d $LZA_DIR ]]; then
  REPO_OWNER="awslabs"
  REPO_HOST="github.com"
  echo -e "\n==> Cloning LZA repository using ${GIT_CLONE_METHOD^^} method"
  if [[ ${GIT_CLONE_METHOD,,} == "ssh" ]]; then
    REPO_URL="git@$REPO_HOST:$REPO_OWNER/$LZA_DIR.git"
  elif [[ ${GIT_CLONE_METHOD,,} == "https" ]]; then
    REPO_URL="https://$REPO_HOST/$REPO_OWNER/$LZA_DIR.git"
  else
    echo "Unsupported GIT_CLONE_METHOD: $GIT_CLONE_METHOD" >&2
    exit 1
  fi
  git clone "$REPO_URL" "$LZA_DIR"
fi

echo -e "\n==> Updating LZA repository"
git -C "$LZA_DIR" switch main
git -C "$LZA_DIR" pull --prune --tags
git -C "$LZA_DIR" remote prune origin

echo -e "\n==> Switching to LZA tag: $REL_TAG"
git -C "$LZA_DIR" -c advice.detachedHead=false checkout "$REL_TAG"

if [[ $RM_IMG_BEFORE_BUILD == "true" ]]; then
	# shellcheck disable=SC2207 # Prefer mapfile or read -a to split command output (or quote to avoid splitting)
	IMAGE_IDS=($($TOOLING images --filter label="$IMG_NAME=$REL_TAG" --noheading --format "{{ .ID }}"))
	if [[ ${IMAGE_IDS[*]} ]]; then
		echo -e "\n==> Deleting existing LZA $REL_TAG Docker image(s): ${IMAGE_IDS[*]}"
		$TOOLING rmi "${IMAGE_IDS[@]}"
	fi
fi

echo -e "\n==> Building LZA $REL_TAG Docker image"
$TOOLING build --build-arg "release=$REL_TAG" --tag "$IMG_NAME:$REL_TAG" --label "$IMG_NAME=$REL_TAG" .

echo -e "\n==> Listing LZA Docker images"
$TOOLING images --filter "label=$IMG_NAME"
