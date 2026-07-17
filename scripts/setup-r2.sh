#!/bin/bash
# Setup Cloudflare R2 for Puchi media storage.
# Does not commit or print secret values — export env vars locally before running.
set -euo pipefail

BUCKET="${R2_BUCKET:-puchi-media}"
NAMESPACE="${NAMESPACE:-puchi-backend}"
SECRET_NAME="media-r2-credentials"
ACCOUNT_ID="${R2_ACCOUNT_ID:-}"

echo "=== Cloudflare R2 setup for Puchi ==="
echo "Bucket: $BUCKET"
echo "Namespace: $NAMESPACE"
echo ""

if command -v wrangler >/dev/null 2>&1; then
  echo "Creating R2 bucket (if missing)..."
  wrangler r2 bucket create "$BUCKET" || echo "  bucket may already exist"
else
  echo "Install wrangler to create the bucket:"
  echo "  wrangler r2 bucket create $BUCKET"
fi

echo ""
echo "Configure public CDN (custom domain) for lesson_image / lesson_audio in Cloudflare dashboard."
echo "Expected CDN base URL: https://cdn.puchi.io.vn"
echo ""

if [ -z "${R2_ACCESS_KEY_ID:-}" ] || [ -z "${R2_SECRET_ACCESS_KEY:-}" ]; then
  echo "Set R2_ACCESS_KEY_ID and R2_SECRET_ACCESS_KEY, then re-run to create the cluster secret:"
  echo "  export R2_ACCESS_KEY_ID=..."
  echo "  export R2_SECRET_ACCESS_KEY=..."
  echo "  $0"
  exit 0
fi

echo "Applying Kubernetes secret $SECRET_NAME (values from env, not logged)..."
kubectl create secret generic "$SECRET_NAME" \
  --namespace "$NAMESPACE" \
  --from-literal=R2_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID" \
  --from-literal=R2_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

if [ -n "$ACCOUNT_ID" ]; then
  echo ""
  echo "Update media ConfigMap endpoint to:"
  echo "  https://${ACCOUNT_ID}.r2.cloudflarestorage.com"
fi

echo ""
echo "=== R2 setup complete ==="
