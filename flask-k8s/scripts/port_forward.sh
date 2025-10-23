#!/bin/bash
set -euo pipefail

port_forward_app() {
    echo "[INFO] Forwarding port 5000 from hello-flask service to localhost..."
    echo "[INFO] Starting port forward in background..."
    minikube kubectl -- port-forward svc/hello-flask 5000:5000 &
    PORT_FORWARD_PID=$!

    echo "[INFO] Port forward PID: $PORT_FORWARD_PID"
    echo "[INFO] Waiting 3 seconds for port forward to establish..."
    sleep 3

    echo "[INFO] Testing the service..."
    curl -s http://localhost:5000 || echo "[ERROR] Curl failed"

    echo "[INFO] Killing port forward process..."
    kill $PORT_FORWARD_PID || true

    echo "[INFO] Done!"
}

# Run function
port_forward_app
