#!/usr/bin/env bash
# Setup Garage buckets for Puchi
# Run on K3s node after Garage is deployed

set -euo pipefail

GARAGE_NS="platform"
GARAGE_POD="garage-0"
GARAGE_ADMIN_TOKEN="change-me-garage-admin-token"

echo "=== Creating Puchi buckets in Garage ==="

# Garage admin API is on port 3903 inside the cluster
GARAGE_ENDPOINT="http://garage.$GARAGE_NS.svc.cluster.local:3903"

# Create buckets
for bucket in puchi-audio puchi-images puchi-avatars puchi-backups; do
  echo "Creating bucket: $bucket"
  kubectl exec -n "$GARAGE_NS" "$GARAGE_POD" -- \
    /garage bucket create "$bucket" --endpoint "$GARAGE_ENDPOINT"
done

# Create access key for Puchi app
echo "Creating access key for puchi-app..."
KEY_OUTPUT=$(kubectl exec -n "$GARAGE_NS" "$GARAGE_POD" -- \
  /garage key create puchi-app --endpoint "$GARAGE_ENDPOINT")

echo "$KEY_OUTPUT"

# Allow access keys to buckets
for bucket in puchi-audio puchi-images puchi-avatars; do
  kubectl exec -n "$GARAGE_NS" "$GARAGE_POD" -- \
    /garage bucket allow "$bucket" \
      --read --write --owner \
      --key puchi-app \
      --endpoint "$GARAGE_ENDPOINT"
  echo "  Allowed puchi-app to $bucket"
done

echo "=== Garage setup complete ==="
echo "Use the Access Key ID and Secret Key above in Puchi backend config."
