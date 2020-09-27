#!/usr/bin/env bash
# Tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`

# Step 1:
# Create dockerpath
# dockerpath=<your docker ID/path>
dockerpath=webdeveddie/greendeploymentimage

# Step 2:  
# Authenticate & tag
echo "Docker ID and Image: $dockerpath"
docker login --username webdeveddie
docker tag greendeploymentimage webdeveddie/greendeploymentimage

# Step 3:
# Push image to a docker repository
docker push webdeveddie/greendeploymentimage