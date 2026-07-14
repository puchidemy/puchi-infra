# Puchi Infra

Infrastructure as Code cho Puchi platform — ArgoCD GitOps trên K3s.

## Cluster

| Node | IP | Role |
|------|-----|------|
| k3s-node1 | 192.168.100.201 | control-plane, etcd |
| k3s-node2 | 192.168.100.202 | control-plane, etcd |
| k3s-node3 | 192.168.100.203 | control-plane, etcd |

K3s v1.35.5, 3 node HA, storage: `local-path` (rancher.io).

## Services đã có sẵn (dùng chung)

Các service này đang chạy cho dự án Arda, Puchi sẽ dùng chung:

| Service | Namespace | Cách dùng cho Puchi |
|---------|-----------|---------------------|
| **CloudNativePG** | cnpg-system | Tạo cluster `pg-puchi`, `pg-supertokens` |
| **NATS** | platform | Subject prefix `puchi.*` |
| **Garage (S3)** | platform | Bucket `puchi-*` |
| **Valkey (Redis)** | platform | DB index riêng |
| **Traefik** | kube-system | Ingress controller, dùng TLS terminate |
| **ArgoCD** | argocd | GitOps deploy |
| **Cloudflare Tunnel** | platform | Expose service ra internet |

## Services cần deploy cho Puchi

| Service | Chart | Namespace | Trạng thái |
|---------|-------|-----------|------------|
| PostgreSQL cluster | CloudNativePG CRD | puchi-db | 📝 Code sẵn |
| Supertoken | supertokens/supertokens | puchi-infra | 📝 Code sẵn |
| Envoy Gateway | envoy/gateway-helm | envoy-gateway-system | 📝 Code sẵn |

## Cấu trúc repo

```
puchi-infra/
├── argocd/
│   ├── projects/infra.yaml      # AppProject: puchi
│   └── apps/
│       ├── root.yaml             # App of Apps root
│       ├── puchi-db.yaml         # PostgreSQL cluster
│       ├── supertokens.yaml      # Supertoken auth
│       └── envoy-gateway.yaml    # Envoy Gateway
├── infra/
│   └── postgres-cluster/        # CloudNativePG Cluster CRDs
├── scripts/
│   ├── bootstrap.sh             # ArgoCD bootstrap
│   ├── setup-garage.sh          # Tạo bucket Garage cho Puchi
│   └── setup-nats.sh            # Tạo NATS stream cho Puchi
└── README.md
```

## Triển khai

### 1. ArgoCD bootstrap

```bash
# SSH vào node K3s
ssh hoan@192.168.100.201

# Apply project + root app
kubectl apply -f argocd/projects/
kubectl apply -f argocd/apps/root.yaml
```

ArgoCD sẽ tự động sync tất cả Application trong `argocd/apps/`.

### 2. Setup Garage buckets

```bash
bash scripts/setup-garage.sh
```

### 3. Setup NATS streams

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
buckets: puchi-audio, puchi-images, puchi-avatars
```

### Valkey (Redis)

```
host: valkey-node.platform.svc.cluster.local
port: 6379
db: 1 (or higher, avoid conflict with Arda)
```

## Domains

- `auth.puchi.io.vn` — Supertoken API
- `api.puchi.io.vn` — Envoy Gateway (backend API)

> **Note:** Cluster chưa có cert-manager. HTTPS được xử lý qua Cloudflare Tunnel ở layer ngoài.
