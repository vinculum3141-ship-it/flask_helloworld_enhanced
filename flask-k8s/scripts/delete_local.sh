#!/bin/bash
set -e

cleanup_app() {
    echo "[INFO] Deleting Service, Deployment, ConfigMap, Secret..."
    kubectl delete -f k8s/service.yaml --ignore-not-found
    kubectl delete -f k8s/deployment.yaml --ignore-not-found
    kubectl delete -f k8s/configmap.yaml --ignore-not-found
    kubectl delete -f k8s/secret.yaml --ignore-not-found

    echo "[INFO] Cleanup complete."
}

# Run function
cleanup_app
