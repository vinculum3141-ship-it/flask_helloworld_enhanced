#!/bin/bash
set -e

deploy_app() {
    echo "[INFO] Applying ConfigMap..."
    kubectl apply -f k8s/configmap.yaml

    echo "[INFO] Applying Secret..."
    kubectl apply -f k8s/secret.yaml

    echo "[INFO] Deploying Deployment & Service..."
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml

    echo "[INFO] Waiting for deployment rollout..."
    kubectl rollout status deployment/hello-flask
    echo "[INFO] App deployed successfully."
}

# Run function
deploy_app
