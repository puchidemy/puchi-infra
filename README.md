# Puchi Infra

Infrastructure as Code cho Puchi platform — ArgoCD GitOps trên K3s.

## Kiến trúc

```
puchi-infra/
├── argocd/
│   ├── projects/           # ArgoCD AppProject definitions
│   └── apps/               # Application CRDs (App of Apps)
├── infra/                  # Infrastructure manifests
│   ├── cnpg/               # CloudNativePG operator
│   ├── postgres-cluster/   # PostgreSQL cluster instances
│   ├── redis/              # Redis Helm values
│   ├── nats/               # NATS Helm values
│   ├── garage/             # Garage object storage
│   ├── supertokens/        # Supertoken Helm values
│   ├── envoy-gateway/      # Envoy Gateway Helm values
│   └── monitoring/         # Prometheus + Grafana
├── apps/                   # Puchi backend service configs
└── scripts/                # Helper scripts
```

## Triển khai

### Prerequisites

- K3s cluster
- ArgoCD installed
- Helm installed
- Storage class configured

### Bootstrap

```bash
# SSH vào node K3s
git clone https://github.com/puchidemy/puchi-infra.git
cd puchi-infra
bash scripts/bootstrap.sh
```

ArgoCD sẽ tự động sync tất cả Application.

## Infrastructure Services

| Service | Chart | Namespace |
|---------|-------|-----------|
| CloudNativePG | cloudnative-pg | cnpg-system |
| PostgreSQL Clusters | custom CRDs | puchi-db |
| Redis | bitnami/redis | puchi-infra |
| NATS | nats/nats | puchi-infra |
| Garage | custom manifests | puchi-storage |
| Supertoken | supertokens/supertokens | puchi-infra |
| Envoy Gateway | envoy/gateway-helm | envoy-gateway-system |
| Prometheus + Grafana | kube-prometheus-stack | puchi-monitoring |

## Domains

- `auth.puchi.io.vn` — Supertoken API
- `api.puchi.io.vn` — Envoy Gateway (Puchi API)
- `monitoring.puchi.io.vn` — Grafana
