#!/bin/bash
# Create cluster secret for Tino SMTP (used by notification-service).
# Does not commit or print secret values.
set -euo pipefail

NAMESPACE="${NAMESPACE:-puchi-backend}"
SECRET_NAME="notification-smtp"

echo "=== Tino SMTP secret for notification ==="
echo "Host (in Deployment): smtp.tino.vn:587"
echo ""

if [ -z "${SMTP_USERNAME:-}" ] || [ -z "${SMTP_PASSWORD:-}" ] || [ -z "${SMTP_FROM_EMAIL:-}" ]; then
  echo "Export then re-run:"
  echo "  export SMTP_USERNAME='noreply@puchi.io.vn'"
  echo "  export SMTP_PASSWORD='...'"
  echo "  export SMTP_FROM_EMAIL='noreply@puchi.io.vn'"
  echo "  $0"
  exit 0
fi

kubectl create secret generic "$SECRET_NAME" \
  --namespace "$NAMESPACE" \
  --from-literal=SMTP_USERNAME="$SMTP_USERNAME" \
  --from-literal=SMTP_PASSWORD="$SMTP_PASSWORD" \
  --from-literal=SMTP_FROM_EMAIL="$SMTP_FROM_EMAIL" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Applied secret $SECRET_NAME — restart notification to pick up:"
echo "  kubectl rollout restart deployment/notification -n $NAMESPACE"
