#!/bin/bash
set -e

BRANCH=${1:-dev}
IMAGE_NAME="webapp"

echo "Building Docker image..."
docker build -t $IMAGE_NAME:latest .

echo "Build complete."
