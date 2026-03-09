#!/bin/bash
set -e

# Usage: ./deploy.sh <branch_name>
BRANCH=${1:-dev}

DOCKER_USER=${DOCKER_USER:-aarushisuba}

DEV_IMAGE="$DOCKER_USER/dev:$BRANCH"
PROD_IMAGE="$DOCKER_USER/prod:$BRANCH"

# Stop existing containers
echo "Stopping old containers..."
docker compose down || true

# Select image based on branch
if [ "$BRANCH" == "dev" ]; then
    IMAGE=$DEV_IMAGE
elif [ "$BRANCH" == "master" ]; then
    IMAGE=$PROD_IMAGE
else
    echo "Invalid branch. Use dev or master"
    exit 1
fi

echo "Deploying image: $IMAGE"

# Export environment variable for docker-compose
export IMAGE=$IMAGE

# Pull latest image
docker compose pull

# Start containers
docker compose up -d

echo "Deployment completed successfully!"
docker compose ps
