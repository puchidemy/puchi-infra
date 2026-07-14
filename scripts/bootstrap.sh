#!/usr/bin/env bash
# Bootstrap ArgoCD with root Application
# Run this on the K3s cluster after cloning puchi-infra

set -euo pipefail

echo "=== Applying ArgoCD Projects ==="
kubectl apply -f argocd/projects/

echo "=== Applying Root Application ==="
kubectl apply -f argocd/apps/root.yaml

echo "=== Done ==="
echo "ArgoCD will now sync all applications automatically."
echo "Check status: argocd app list"
