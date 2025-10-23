#!/bin/bash
set -e

deploy_app() {
    echo "[INFO] Applying ConfigMap..."
    minikube kubectl -- apply -f k8s/configmap.yaml

    echo "[INFO] Applying Secret..."
    minikube kubectl -- apply -f k8s/secret.yaml

    echo "[INFO] Deploying Deployment & Service..."
    minikube kubectl -- apply -f k8s/deployment.yaml
    minikube kubectl -- apply -f k8s/service.yaml

    echo "[INFO] Waiting for deployment rollout..."
    # add a timeout so this step doesn't hang indefinitely
    minikube kubectl -- rollout status deployment/hello-flask --timeout=5m
    echo "[INFO] App deployed successfully."
}

# Run function
deploy_app
