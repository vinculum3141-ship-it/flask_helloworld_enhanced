#!/bin/bash
set -e

# Function: build Docker image for Minikube
build_image() {
    echo "[INFO] Switching to Minikube Docker environment..."
    eval $(minikube docker-env)

    echo "[INFO] Building Docker image 'hello-flask:latest'..."
    docker build -t hello-flask:latest ./app

    echo "[INFO] Docker image built successfully."
    docker images | grep hello-flask

}

# Run function
build_image
