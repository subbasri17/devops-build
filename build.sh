#!/bin/bash
set -e

BRANCH=${1:-dev}   # default to dev
IMAGE_NAME="webapp"
DOCKER_USER=${DOCKER_USER:-aarushisuba}

DEV_IMAGE="$DOCKER_USER/dev:$BRANCH"
PROD_IMAGE="$DOCKER_USER/prod:$BRANCH"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME:latest" .

# Check if Docker credentials exist
if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASS" ]; then
    echo "Error: DOCKER_USER or DOCKER_PASS is not set!"
    exit 1
fi

echo "Logging in to DockerHub..."
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

if [ "$BRANCH" == "dev" ]; then
    IMAGE="$DEV_IMAGE"
elif [ "$BRANCH" == "master" ]; then
    IMAGE="$PROD_IMAGE"
else
    echo "Unknown branch '$BRANCH'. Only dev or master allowed."
    exit 1
fi

echo "Tagging image $IMAGE_NAME:latest -> $IMAGE"
docker tag "$IMAGE_NAME:latest" "$IMAGE"

echo "Pushing image to DockerHub..."
docker push "$IMAGE"

echo "Build and push complete!"
