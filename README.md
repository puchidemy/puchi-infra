# Puchi Infra

Infrastructure as Code cho Puchi platform — **ArgoCD GitOps** trên K3s.

## Cluster

| Node | IP | Role |
|------|-----|------|
| k3s-node1 | 192.168.100.201 | control-plane, etcd |
| k3s-node2 | 192.168.100.202 | control-plane, etcd |
| k3s-node3 | 192.168.100.203 | control-plane, etcd |

**K3s v1.35.5** — 3 node HA, storage: `local-path`, ingress: Traefik.

## Cấu trúc repo

```
puchi-infra/
├── argocd/
│   ├── projects/infra.yaml       # AppProject: puchi
│   └── apps/
│       ├── root.yaml             # App of Apps root
│       ├── repo-creds.yaml       # GitHub PAT
│       ├── puchi-db.yaml         # PostgreSQL cluster
│       ├── auth-service.yaml     # Auth service
│       └── envoy-gateway.yaml    # Envoy Gateway
├── infra/
│   └── postgres-cluster/        # CloudNativePG Cluster CRDs
├── scripts/
│   ├── bootstrap.sh             # 1-command ArgoCD bootstrap
│   ├── setup-garage.sh          # Garage buckets + key
│   └── setup-nats.sh            # NATS streams
├── .cursor/rules/
│   ├── project.mdc              # Project overview
│   ├── argocd.mdc               # App of Apps conventions
│   └── k8s-manifests.mdc        # K8s manifest conventions
└── README.md
```

## Services

### Shared (dùng chung với Arda)

| Service | Namespace | Cách dùng cho Puchi |
|---------|-----------|---------------------|
| **CloudNativePG** | cnpg-system | Tạo cluster `pg-puchi` |
| **NATS** | platform | Subject prefix `puchi.*` |
| **Garage (S3)** | platform | Bucket `puchi-*` |
| **Valkey (Redis)** | platform | DB index riêng |
| **Traefik** | kube-system | Ingress controller |
| **ArgoCD** | argocd | GitOps deploy |
| **Cloudflare Tunnel** | platform | Expose ra internet |

### Deployed cho Puchi

| Service | Chart | Namespace | Trạng thái |
|---------|-------|-----------|------------|
| PostgreSQL 18 | CloudNativePG CRD | puchi-db | ✅ Running |
| Auth Service | custom Helm | puchi-backend | ✅ Deployed |
| Envoy Gateway | envoy/gateway-helm | envoy-gateway-system | ✅ Deployed |

## Triển khai

### Bootstrap

```bash
ssh hoan@192.168.100.201

# Apply ArgoCD project + root app
kubectl apply -f argocd/projects/
kubectl apply -f argocd/apps/root.yaml
```

ArgoCD sẽ tự động sync tất cả Application.

### Setup Garage buckets

```bash
bash scripts/setup-garage.sh
```

### Setup NATS streams

```bash
bash scripts/setup-nats.sh
```

## Kết nối từ Puchi Backend

### PostgreSQL

```
host: pg-puchi-rw.puchi-db.svc.cluster.local
port: 5432
database: puchi
user: puchi (secret: pg-puchi-app-secret)
```

### NATS

```
url: nats://nats.platform.svc.cluster.local:4222
subject prefix: puchi.*
```

### Garage (S3)

```
endpoint: http://garage.platform.svc.cluster.local:3900
region: puchi
buckets: puchi-audio, puchi-images, puchi-avatars, puchi-backups
```

### Valkey (Redis)

```
host: valkey-node.platform.svc.cluster.local
port: 6379
db: 1 (avoid conflict with Arda)
```

## Domains

- `api.puchi.io.vn` — Envoy Gateway (auth + backend API)

> **Note:** HTTPS qua Cloudflare Tunnel, chưa có cert-manager.
