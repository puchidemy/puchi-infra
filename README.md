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
│   ├── projects/infra.yaml
│   └── apps/                    # App of Apps
├── infra/
│   ├── postgres-cluster/
│   ├── envoy-gateway/
│   ├── frontend/web/
│   └── backend/                 # auth, core, learn, media, notification
├── scripts/
│   ├── bootstrap.sh
│   ├── setup-r2.sh              # R2 + media-r2-credentials
│   ├── setup-smtp.sh            # Tino → notification-smtp
│   └── setup-nats.sh
└── README.md
```

## Services

### Shared (dùng chung với Arda)

| Service | Namespace | Cách dùng cho Puchi |
|---------|-----------|---------------------|
| **CloudNativePG** | cnpg-system | Cluster `pg-puchi` |
| **NATS** | platform | Events (`email.send`, `learn.*`, …) |
| **Valkey (Redis)** | platform | Cache |
| **Traefik** | kube-system | Ingress |
| **ArgoCD** | argocd | GitOps |
| **Cloudflare Tunnel** | platform | Expose internet |

Object storage Puchi dùng **Cloudflare R2** (không phụ thuộc Garage cho media).

### Deployed cho Puchi

| Service | Namespace |
|---------|-----------|
| PostgreSQL 18 | puchi-db |
| Envoy Gateway | envoy-gateway-system |
| Frontend | puchi-frontend |
| Backend (auth, core, learn, media, notification) | puchi-backend |

## Triển khai

```bash
ssh hoan@192.168.100.201
kubectl apply -f argocd/projects/
kubectl apply -f argocd/apps/root.yaml
```

### Secrets (cluster-only, không commit)

```bash
# R2
export R2_ACCOUNT_ID=... R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=...
bash scripts/setup-r2.sh

# Tino SMTP (notification)
export SMTP_USERNAME=... SMTP_PASSWORD=... SMTP_FROM_EMAIL=...
bash scripts/setup-smtp.sh
```

### NATS

```bash
bash scripts/setup-nats.sh
```

## Kết nối

### PostgreSQL

```
host: pg-puchi-rw.puchi-db.svc.cluster.local
port: 5432
database: puchi
```

### NATS

```
url: nats://nats.platform.svc.cluster.local:4222
```

### R2 (media)

```
endpoint: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
bucket: puchi-media
cdn: https://cdn.puchi.io.vn
secret: media-r2-credentials
```

### SMTP (notification)

```
host: smtp.tino.vn:587
secret: notification-smtp
```

### Valkey

```
host: valkey-node.platform.svc.cluster.local:6379
```

## Domains

- `puchi.io.vn` — Frontend
- `api.puchi.io.vn` — Envoy (auth + API)
- `cdn.puchi.io.vn` — R2 public CDN
- OAuth: `https://api.puchi.io.vn/auth/oauth/{google|facebook|tiktok}/callback`
- Secrets: `auth-limen-secret`, `auth-oauth-credentials`, `media-r2-credentials`, `notification-smtp`
