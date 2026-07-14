#!/bin/bash
# Setup Garage buckets for Puchi via admin API
# Garage v2.x - uses /v2/CreateBucket and /v2/ListBuckets endpoints
set -e

GARAGE_IP=$(kubectl get svc -n platform garage -o jsonpath='{.spec.clusterIP}')
# Get admin token from garage configmap
ADMIN_TOKEN=$(kubectl get cm -n platform garage-config -o jsonpath='{.data.garage\.toml}' | grep 'admin_token' | cut -d'"' -f2)
API="http://$GARAGE_IP:3903"

echo "Garage admin API: $API"
echo ""

echo "=== Creating Puchi buckets ==="
for bucket in puchi-audio puchi-images puchi-avatars puchi-backups; do
  echo "  Bucket: $bucket"
  result=$(curl -s -X POST \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"globalAlias\": \"$bucket\"}" \
    "$API/v2/CreateBucket")
  echo "    $result"
done

echo ""
echo "=== Listing Puchi buckets ==="
curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$API/v2/ListBuckets" | python3 -m json.tool 2>/dev/null || \
curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$API/v2/ListBuckets"

echo ""
echo "=== Garage setup complete ==="
