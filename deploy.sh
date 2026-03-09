#!/bin/bash
set -e

BRANCH=${1:-dev}
TAG=${2:-latest}

DOCKER_USER="aarushisuba"

if [ "$BRANCH" == "dev" ]; then
    IMAGE="$DOCKER_USER/dev:$TAG"
elif [ "$BRANCH" == "main" ]; then
    IMAGE="$DOCKER_USER/prod:$TAG"
else
    echo "Invalid branch. Use dev or main"
    exit 1
fi

echo "Stopping old containers..."
docker-compose down || true

echo "Deploying image: $IMAGE"

export IMAGE=$IMAGE

docker-compose pull
docker-compose up -d

docker-compose ps

echo "Deployment completed successfully!"
