#!/bin/sh
# Setup NATS streams for Puchi
set -e

NATS_NS="platform"
NATS_BOX_POD=$(kubectl get pod -n "$NATS_NS" -l app.kubernetes.io/name=nats-box -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$NATS_BOX_POD" ]; then
  echo "ERROR: nats-box pod not found"
  exit 1
fi

echo "=== Setting up NATS for Puchi ==="

echo "Creating stream: puchi-lessons"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-lessons \
    --subjects "puchi.lesson.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=1GB \
    --retention limits \
    --discard old 2>&1 || echo "  maybe already exists"

echo "Creating stream: puchi-gaming"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-gaming \
    --subjects "puchi.game.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=500MB \
    --retention limits \
    --discard old 2>&1 || echo "  maybe already exists"

echo "Creating stream: puchi-notifications"
kubectl exec -n "$NATS_NS" "$NATS_BOX_POD" -- \
  nats str add puchi-notifications \
    --subjects "puchi.notify.>" \
    --storage file \
    --max-msgs=-1 \
    --max-bytes=500MB \
    --retention limits \
    --discard old 2>&1 || echo "  maybe already exists"

echo ""
echo "=== NATS Setup Complete ==="
