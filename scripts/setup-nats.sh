#!/usr/bin/env bash
# Setup NATS streams/subjects for Puchi
# Run on K3s node

set -euo pipefail

NATS_NS="platform"
NATS_BOX_POD=$(kubectl get pod -n "$NATS_NS" -l app.kubernetes.io/name=nats-box -o jsonpath='{.items[0].metadata.name}')

echo "=== Setting up NATS for Puchi ==="

# Create streams for Puchi domain events
# Each stream has subject prefix puchi.*

echo "Creating stream: puchi-lessons"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-lessons \
    --subjects "puchi.lesson.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=1GB \
    --retention limits \
    --discard old

echo "Creating stream: puchi-gaming"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-gaming \
    --subjects "puchi.game.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=500MB \
    --retention limits \
    --discard old

echo "Creating stream: puchi-notifications"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-notifications \
    --subjects "puchi.notify.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=500MB \
    --retention limits \
    --discard old

echo ""
echo "=== NATS Setup Complete ==="
echo "Streams created. Puchi services use subject prefix: puchi.*"
