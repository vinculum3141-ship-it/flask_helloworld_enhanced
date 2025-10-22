#!/bin/bash
set -e

get_service_url() {
    echo "[INFO] Fetching service URL..."
    URL=$(minikube service hello-flask --url)
    echo "[INFO] Access your app at: $URL"
    curl -s $URL || echo "[ERROR] Curl failed"
}

# Run function
get_service_url
